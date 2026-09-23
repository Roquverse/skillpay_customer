class ChatModel {
  final String id;
  final String artisanId;
  final String artisanName;
  final String artisanAvatarUrl;
  final String lastMessage;
  final String timeText;
  final int unreadCount;
  final DateTime updatedAt;
  final String? jobId;
  final String? jobTitle;

  ChatModel({
    required this.id,
    required this.artisanId,
    required this.artisanName,
    required this.artisanAvatarUrl,
    required this.lastMessage,
    required this.timeText,
    required this.unreadCount,
    required this.updatedAt,
    this.jobId,
    this.jobTitle,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    final artisanData = (map['artisan'] is Map)
        ? Map<String, dynamic>.from(map['artisan'] as Map)
        : <String, dynamic>{};

    final updatedAt = map['updatedAt'] != null
        ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
        : (map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now());

    final diff = DateTime.now().difference(updatedAt);
    String timeText = 'Just now';
    if (diff.inDays > 0) {
      timeText = '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      timeText = '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      timeText = '${diff.inMinutes}m';
    }

    final String artisanName = artisanData['fullName']?.toString() ??
        artisanData['full_name']?.toString() ??
        artisanData['businessName']?.toString() ??
        map['artisan_name']?.toString() ??
        'Artisan';

    final String avatarUrl = artisanData['profilePhoto']?.toString() ??
        artisanData['profile_image_url']?.toString() ??
        map['artisan_avatar_url']?.toString() ??
        'assets/images/avatar_james.png';

    return ChatModel(
      id: map['id']?.toString() ?? '',
      artisanId: artisanData['id']?.toString() ?? map['artisan_id']?.toString() ?? '',
      artisanName: artisanName,
      artisanAvatarUrl: avatarUrl,
      lastMessage: map['lastMessage']?.toString() ?? map['last_message']?.toString() ?? '...',
      timeText: map['time_text']?.toString() ?? timeText,
      unreadCount: (map['unreadCount'] as int?) ?? (map['unread_count'] as int?) ?? 0,
      updatedAt: updatedAt,
      jobId: map['jobId']?.toString() ?? map['job_id']?.toString(),
      jobTitle: map['jobTitle']?.toString() ?? map['job_title']?.toString(),
    );
  }
}
