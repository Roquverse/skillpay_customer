import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/services/messages_service.dart';
import 'package:skillpay/models/chat_model.dart';
import 'package:skillpay/screens/chat_screen.dart';
import 'package:skillpay/widgets/chat_skeleton.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MessagesService _messagesService = MessagesService();
  late Future<List<ChatModel>> _chatsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatsFuture = _messagesService.fetchChats();
  }

  Future<void> _refreshChats() async {
    setState(() {
      _chatsFuture = _messagesService.fetchChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Messages',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<ChatModel>>(
              future: _chatsFuture,
              initialData: _messagesService.getCachedChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const ConversationListSkeleton();
                }

                if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: _refreshChats,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Text(
                            'Error loading messages. Pull to retry.',
                            style: GoogleFonts.outfit(
                                color: AppColors.textMedium),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final chats = snapshot.data ?? [];
                final filteredChats = _searchQuery.isEmpty
                    ? chats
                    : chats.where((c) {
                        final q = _searchQuery.toLowerCase();
                        return c.artisanName.toLowerCase().contains(q) ||
                            c.lastMessage.toLowerCase().contains(q);
                      }).toList();

                if (filteredChats.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshChats,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: _buildEmptyState(),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshChats,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = filteredChats[index];
                      return _buildChatItem(chat);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: GoogleFonts.outfit(
                  color: const Color(0xFFB0B0B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B0B0),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'No conversations found'
                : 'No messages yet',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search keyword'
                : 'When you message an artisan, it will appear here',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textMedium.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatModel chat) {
    final hasNetworkAvatar = chat.artisanAvatarUrl.startsWith('http');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: chat.id,
              artisanName: chat.artisanName,
              artisanAvatarUrl: chat.artisanAvatarUrl,
            ),
          ),
        ).then((_) => _refreshChats());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F5F5),
                image: chat.artisanAvatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: hasNetworkAvatar
                            ? NetworkImage(chat.artisanAvatarUrl)
                                as ImageProvider
                            : AssetImage(chat.artisanAvatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: chat.artisanAvatarUrl.isEmpty
                  ? Center(
                      child: Text(
                        chat.artisanName.isNotEmpty
                            ? chat.artisanName[0].toUpperCase()
                            : 'A',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.artisanName,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage.isNotEmpty
                        ? chat.lastMessage
                        : 'Tap to view conversation',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: chat.unreadCount > 0
                          ? AppColors.textDark
                          : AppColors.textMedium,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Timestamp & unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.timeText,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
