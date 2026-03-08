import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String message;
  final String type; // 'payment', 'job', 'proposal', 'general'
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      message: map['message']?.toString() ??
          map['title']?.toString() ??
          'You have a new notification',
      type: map['type']?.toString() ?? 'general',
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Returns a suitable icon based on the notification type.
  IconData get icon {
    switch (type) {
      case 'payment':
        return Icons.attach_money_rounded;
      case 'job':
        return Icons.work_outline_rounded;
      case 'proposal':
        return Icons.description_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  /// Returns a human-readable time string.
  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today ${DateFormat('hh:mm a').format(createdAt)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${DateFormat('hh:mm a').format(createdAt)}';
    } else {
      return DateFormat('MMM d, hh:mm a').format(createdAt);
    }
  }
}
