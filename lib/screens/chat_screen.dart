import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/models/message_model.dart';
import 'package:skillpay/services/messages_service.dart';
import 'package:skillpay/services/cloudinary_service.dart';
import 'package:skillpay/widgets/chat_skeleton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  final String artisanName;
  final String? conversationId;
  final String? artisanAvatarUrl;

  const ChatScreen({
    super.key,
    required this.artisanName,
    this.conversationId,
    this.artisanAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessagesService _messagesService = MessagesService();
  final CloudinaryService _cloudinary = CloudinaryService.instance;
  final AudioRecorder _recorder = AudioRecorder();
  final Map<String, AudioPlayer> _players = {};

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  String? _myUserId;

  // Track playback state per message
  final Map<String, PlayerState> _playerStates = {};
  final Map<String, Duration> _playerPositions = {};
  final Map<String, Duration> _playerDurations = {};

  late AnimationController _recordPulse;

  @override
  void initState() {
    super.initState();
    _myUserId = Supabase.instance.client.auth.currentUser?.id;
    _recordPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    if (widget.conversationId != null) {
      final cached = _messagesService.getCachedMessages(widget.conversationId!);
      if (cached != null && cached.isNotEmpty) {
        _messages = List.from(cached);
        _isLoading = false;
      }
      _loadMessages();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadMessages() async {
    if (widget.conversationId == null) return;
    try {
      final msgs = await _messagesService.fetchMessages(widget.conversationId!);
      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
        _scrollToBottom();
        _messagesService.markSeen(widget.conversationId!);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _recordPulse.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    for (final p in _players.values) {
      p.dispose();
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Attachment picker ──────────────────────────────────────────────────────

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _attachmentTile(
                icon: Icons.image_rounded,
                color: Colors.blue,
                label: 'Photo / Video',
                onTap: () { Navigator.pop(context); _pickImage(); },
              ),
              _attachmentTile(
                icon: Icons.insert_drive_file_rounded,
                color: Colors.red,
                label: 'Document (PDF)',
                onTap: () { Navigator.pop(context); _pickDocument(); },
              ),
              _attachmentTile(
                icon: Icons.mic_rounded,
                color: AppColors.primary,
                label: 'Voice Note',
                onTap: () { Navigator.pop(context); _startVoiceRecording(); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    await _uploadAndSend(File(picked.path));
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result == null || result.files.single.path == null) return;
    await _uploadAndSend(File(result.files.single.path!));
  }

  // ─── Voice recording ────────────────────────────────────────────────────────

  Future<void> _startVoiceRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(RecordConfig(encoder: AudioEncoder.aacLc), path: path);
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });
    _recordPulse.repeat(reverse: true);

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recordDuration += const Duration(seconds: 1));
    });
  }

  Future<void> _stopAndSendVoice() async {
    _recordTimer?.cancel();
    final path = await _recorder.stop();
    setState(() => _isRecording = false);
    _recordPulse.stop();

    if (path == null) return;
    await _uploadAndSend(File(path));
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });
    _recordPulse.stop();
  }

  // ─── Upload + send ──────────────────────────────────────────────────────────

  Future<void> _uploadAndSend(File file, {String text = ''}) async {
    if (widget.conversationId == null) return;
    setState(() => _isUploading = true);

    try {
      final url = await _cloudinary.upload(file);
      await _sendMessage(text: text, attachmentUrls: [url]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _sendMessage({String? text, List<String>? attachmentUrls}) async {
    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty && (attachmentUrls == null || attachmentUrls.isEmpty)) return;

    _messageController.clear();

    if (widget.conversationId != null) {
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final optimistic = MessageModel(
        id: tempId,
        conversationId: widget.conversationId!,
        senderId: _myUserId ?? '',
        senderRole: 'HOMEOWNER',
        message: msgText,
        attachmentUrls: attachmentUrls ?? [],
        seen: false,
        createdAt: DateTime.now(),
        isSending: true,
      );

      setState(() => _messages.add(optimistic));
      _scrollToBottom();

      try {
        final sent = await _messagesService.sendMessage(
          widget.conversationId!,
          msgText,
          attachmentUrls: attachmentUrls,
        );
        if (mounted && sent != null) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == tempId);
            if (idx != -1) _messages[idx] = sent;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == tempId);
            if (idx != -1) {
              _messages[idx].hasError = true;
              _messages[idx].isSending = false;
            }
          });
        }
      }
    } else {
      setState(() {
        _messages.add(MessageModel(
          id: DateTime.now().toIso8601String(),
          conversationId: '',
          senderId: _myUserId ?? '',
          senderRole: 'HOMEOWNER',
          message: msgText,
          attachmentUrls: attachmentUrls ?? [],
          seen: false,
          createdAt: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  // ─── Audio playback ─────────────────────────────────────────────────────────

  AudioPlayer _getPlayer(String url) {
    if (!_players.containsKey(url)) {
      final player = AudioPlayer();
      _players[url] = player;
      player.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _playerStates[url] = state);
      });
      player.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _playerPositions[url] = pos);
      });
      player.onDurationChanged.listen((dur) {
        if (mounted) setState(() => _playerDurations[url] = dur);
      });
    }
    return _players[url]!;
  }

  Future<void> _togglePlay(String url) async {
    final player = _getPlayer(url);
    final state = _playerStates[url] ?? PlayerState.stopped;
    if (state == PlayerState.playing) {
      await player.pause();
    } else {
      await player.play(UrlSource(url));
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final avatarUrl = widget.artisanAvatarUrl ?? '';
    final isNetworkAvatar = avatarUrl.startsWith('http');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
              child: isNetworkAvatar
                  ? Image.network(avatarUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback())
                  : _avatarFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.artisanName,
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isUploading)
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 3,
            ),
          Expanded(child: _buildMessageList()),
          if (_isRecording) _buildRecordingBar() else _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) return const ChatMessagesSkeleton();
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Start a conversation',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Send a message, photo, or voice note',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.senderRole?.toUpperCase() == 'HOMEOWNER' ||
            (msg.senderRole == null && msg.senderId == _myUserId);
        final showHeader = index == 0 ||
            !_isSameDay(_messages[index - 1].createdAt, msg.createdAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) _buildDateDivider(_formatDateHeader(msg.createdAt)),
            _buildBubble(msg, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageModel msg, bool isMe) {
    final time = DateFormat('h:mm a').format(msg.createdAt);
    final hasAttachment = msg.attachmentUrls.isNotEmpty;
    final url = hasAttachment ? msg.attachmentUrls.first : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (url != null) ...[
                  if (CloudinaryService.isVoiceNote(url))
                    _buildVoiceNoteBubble(url, isMe)
                  else if (CloudinaryService.isImage(url))
                    _buildImageBubble(url)
                  else if (CloudinaryService.isDocument(url))
                    _buildDocumentBubble(url, isMe),
                  if (msg.message.isNotEmpty) const SizedBox(height: 6),
                ],
                if (msg.message.isNotEmpty)
                  Text(
                    msg.message,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isMe ? Colors.white.withAlpha(180) : Colors.grey.shade500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      if (msg.isSending)
                        SizedBox(
                          width: 10, height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white.withAlpha(180),
                          ),
                        )
                      else if (msg.hasError)
                        const Icon(Icons.error_outline, size: 12, color: Colors.red)
                      else
                        Icon(
                          msg.seen ? Icons.done_all : Icons.done,
                          size: 13,
                          color: msg.seen ? Colors.white : Colors.white.withAlpha(180),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageBubble(String url) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 220,
          height: 180,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : const SizedBox(
                width: 220, height: 180,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          errorBuilder: (_, __, ___) => const SizedBox(
            width: 220, height: 80,
            child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentBubble(String url, bool isMe) {
    final name = Uri.parse(url).pathSegments.last;
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withAlpha(35) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, color: isMe ? Colors.white : Colors.red.shade400, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isMe ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceNoteBubble(String url, bool isMe) {
    final player = _getPlayer(url);
    final state = _playerStates[url] ?? PlayerState.stopped;
    final position = _playerPositions[url] ?? Duration.zero;
    final duration = _playerDurations[url] ?? const Duration(seconds: 1);
    final isPlaying = state == PlayerState.playing;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _togglePlay(url),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withAlpha(50) : AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isMe ? Colors.white : AppColors.primary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: isMe ? Colors.white : AppColors.primary,
                  inactiveTrackColor: isMe ? Colors.white.withAlpha(80) : Colors.grey.shade300,
                  thumbColor: isMe ? Colors.white : AppColors.primary,
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (v) {
                    final seekTo = Duration(milliseconds: (v * duration.inMilliseconds).round());
                    player.seek(seekTo);
                  },
                ),
              ),
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: isMe ? Colors.white.withAlpha(180) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Recording bar ──────────────────────────────────────────────────────────

  Widget _buildRecordingBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _recordPulse,
                  builder: (_, __) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withAlpha(((_recordPulse.value * 255).round())),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_recordDuration),
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recording...',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _stopAndSendVoice,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input area ─────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attachment button
          GestureDetector(
            onTap: _showAttachmentSheet,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.attach_file_rounded, color: Colors.black54, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send / Mic button
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (_, value, __) {
              final hasText = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: hasText ? () => _sendMessage() : _showAttachmentSheet,
                onLongPress: hasText ? null : _startVoiceRecording,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasText ? Icons.send_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        widget.artisanName.isNotEmpty ? widget.artisanName[0].toUpperCase() : 'A',
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
    );
  }
}
