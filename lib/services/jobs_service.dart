import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/models/job_model.dart';

class JobsService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all jobs for the currently logged-in customer
  Future<List<JobModel>> fetchCustomerJobs() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    // According to schema, the customer who created the job is under `customer_id`
    final response = await _client
        .from('jobs')
        .select()
        .eq('customer_id', user.id)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;
    return data.map((json) => JobModel.fromMap(json)).toList();
  }

  /// Create a new job
  Future<void> createJob(JobModel job) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    final postData = job.toMap();
    // Enforce the current user is the customer
    postData['customer_id'] = user.id;

    await _client.from('jobs').insert(postData);
  }
}
