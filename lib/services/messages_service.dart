import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class MessagesService {
  final _api = ApiClient.instance;
  static List<ChatModel>? _cachedChats;
  static final Map<String, List<MessageModel>> _cachedMessages = {};

  /// Return cached chats if available for instantaneous loading
  List<ChatModel>? getCachedChats() => _cachedChats;

  List<MessageModel>? getCachedMessages(String conversationId) =>
      _cachedMessages[conversationId];

  /// Fetch active chat threads for the logged-in customer via NestJS chat API
  Future<List<ChatModel>> fetchChats() async {
    try {
      final data = await _api.get('/chat/conversations');
      if (data is List) {
        final chats = data
            .map((json) => ChatModel.fromMap(json as Map<String, dynamic>))
            .toList();
        _cachedChats = chats;
        return chats;
      }
      return _cachedChats ?? [];
    } on ApiException catch (e) {
      debugPrint('[MessagesService] API error fetching chats: ${e.message}');
      return _cachedChats ?? [];
    } catch (e) {
      debugPrint('[MessagesService] Error fetching chats: $e');
      return _cachedChats ?? [];
    }
  }

  /// Fetch messages for a specific conversation
  Future<List<MessageModel>> fetchMessages(
    String conversationId, {
    int limit = 40,
    String? before,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        if (before != null) 'before': before,
      };
      final data = await _api.get(
        '/chat/conversations/$conversationId/messages',
        query: query,
      );
      if (data is List) {
        final msgs = data
            .map((json) => MessageModel.fromMap(json as Map<String, dynamic>))
            .toList();
        _cachedMessages[conversationId] = msgs;
        return msgs;
      }
      return _cachedMessages[conversationId] ?? [];
    } on ApiException catch (e) {
      debugPrint('[MessagesService] Error fetching messages: ${e.message}');
      return _cachedMessages[conversationId] ?? [];
    } catch (e) {
      debugPrint('[MessagesService] Error fetching messages: $e');
      return _cachedMessages[conversationId] ?? [];
    }
  }

  /// Send a message in a conversation
  Future<MessageModel?> sendMessage(
    String conversationId,
    String message, {
    List<String>? attachmentUrls,
  }) async {
    try {
      final data = await _api.post(
        '/chat/conversations/$conversationId/messages',
        body: {
          'message': message,
          if (attachmentUrls != null) 'attachmentUrls': attachmentUrls,
          'senderRole': 'HOMEOWNER',
        },
      );
      if (data is Map<String, dynamic>) {
        final newMsg = MessageModel.fromMap(data);
        if (_cachedMessages.containsKey(conversationId)) {
          _cachedMessages[conversationId]?.add(newMsg);
        }
        return newMsg;
      }
      return null;
    } on ApiException catch (e) {
      debugPrint('[MessagesService] Error sending message: ${e.message}');
      throw Exception(e.message);
    }
  }

  /// Mark conversation as seen
  Future<void> markSeen(String conversationId) async {
    try {
      await _api.patch('/chat/conversations/$conversationId/mark-seen');
    } catch (_) {}
  }
}
