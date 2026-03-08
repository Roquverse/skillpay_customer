class ChatModel {
  final String id;
  final String artisanId;
  final String artisanName;
  final String artisanAvatarUrl;
  final String lastMessage;
  final String timeText;
  final int unreadCount;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.artisanId,
    required this.artisanName,
    required this.artisanAvatarUrl,
    required this.lastMessage,
    required this.timeText,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    // Assuming a DB view or join returning artisan info embedded
    final artisanData = map['artisan'] ?? {};
    
    return ChatModel(
      id: map['id'] as String,
      artisanId: map['artisan_id'] as String,
      artisanName: artisanData['full_name'] ?? 'Artisan',
      artisanAvatarUrl: artisanData['profile_image_url'] ?? 'assets/images/avatar_james.png',
      lastMessage: map['last_message'] ?? '...',
      timeText: map['time_text'] ?? 'Just now',
      unreadCount: map['unread_count'] ?? 0,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
    );
  }
}
