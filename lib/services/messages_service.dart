import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/models/chat_model.dart';
import 'package:flutter/foundation.dart';

class MessagesService {
  final SupabaseClient _client = Supabase.instance.client;
  static List<ChatModel>? _cachedChats;

  /// Return cached chats if available for instantaneous loading
  List<ChatModel>? getCachedChats() => _cachedChats;

  /// Fetch active chat threads for the logged-in customer
  Future<List<ChatModel>> fetchChats() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      // Direct PostgREST query if table exists, otherwise gracefully fallback
      final response = await _client
          .from('chats')
          .select('*, artisan:user_profiles!artisan_id(*)')
          .eq('customer_id', user.id)
          .order('updated_at', ascending: false);

      final List<dynamic> data = response;
      final chats = data.map((json) => ChatModel.fromMap(json)).toList();
      _cachedChats = chats;
      return chats;
    } catch (_) {
      // Table 'chats' is managed via NestJS /chat backend or mock dataset during design preview
      return _cachedChats ?? [];
    }
  }
}

