import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/models/proposal_model.dart';
import 'package:flutter/foundation.dart';

class ProposalsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all active proposals for jobs belonging to the current customer
  Future<List<ProposalModel>> fetchProposals() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      // We expect a Supabase view or table relation linking proposals -> jobs & user_profiles.
      // E.g., select('*, artisan:user_profiles!artisan_id(*), job:jobs!inner(*)') 
      // where job.customer_id == user.id
      final response = await _client
          .from('proposals')
          .select('*, artisan:user_profiles!proposals_artisan_id_fkey(*), jobs!inner(*)')
          .eq('jobs.customer_id', user.id)
          .eq('status', 'pending');

      final List<dynamic> data = response;
      return data.map((json) => ProposalModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error fetching proposals from DB: $e');
      // If table doesn't exist yet during prototyping, return empty or mock data
      // For now we will return an empty list if it fails, assuming the DB might not be fully seeded.
      return [];
    }
  }
}
