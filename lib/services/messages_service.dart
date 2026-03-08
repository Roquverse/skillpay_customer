import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/models/chat_model.dart';
import 'package:flutter/foundation.dart';

class MessagesService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch active chat threads for the logged-in customer
  Future<List<ChatModel>> fetchChats() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      // Expecting a table "chats" or "conversations" linking customer_id to artisan_id
      // For this prototyping phase, we attempt a fetch and gracefully fallback if table doesn't exist
      final response = await _client
          .from('chats')
          .select('*, artisan:user_profiles!artisan_id(*)')
          .eq('customer_id', user.id)
          .order('updated_at', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => ChatModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error fetching chats from DB: $e');
      // Graceful fallback during prototyping
      return [];
    }
  }
}
