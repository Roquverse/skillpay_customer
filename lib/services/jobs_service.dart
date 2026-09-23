import 'package:flutter/foundation.dart';
import 'api_client.dart';
import '../models/job_model.dart';

class JobsService {
  final _api = ApiClient.instance;
  static List<JobModel>? _cachedCustomerJobs;

  List<JobModel>? getCachedCustomerJobs() => _cachedCustomerJobs;

  /// Fetch all jobs for the currently logged-in customer/homeowner
  Future<List<JobModel>> fetchCustomerJobs() async {
    try {
      final data = await _api.get('/jobs/my-jobs');
      if (data is List) {
        final jobs = data
            .map((json) => JobModel.fromMap(json as Map<String, dynamic>))
            .toList();
        _cachedCustomerJobs = jobs;
        return jobs;
      }
      return _cachedCustomerJobs ?? [];
    } on ApiException catch (e) {
      debugPrint('[JobsService] API error fetching customer jobs: ${e.message}');
      return _cachedCustomerJobs ?? [];
    } catch (e) {
      debugPrint('[JobsService] Unexpected error: $e');
      return _cachedCustomerJobs ?? [];
    }
  }

  /// Create a new job via NestJS API
  Future<JobModel?> createJob(JobModel job) async {
    try {
      final data = await _api.post('/jobs', body: job.toMap()) as Map<String, dynamic>;
      final created = JobModel.fromMap(data);
      // Invalidate cache
      _cachedCustomerJobs = null;
      return created;
    } on ApiException catch (e) {
      debugPrint('[JobsService] Error creating job: ${e.message}');
      throw Exception(e.message);
    }
  }

  /// Fetch a single job details by ID
  Future<JobModel> fetchJob(String jobId) async {
    try {
      final data = await _api.get('/jobs/$jobId') as Map<String, dynamic>;
      return JobModel.fromMap(data);
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Cancel a job
  Future<void> cancelJob(String jobId) async {
    try {
      await _api.patch('/jobs/$jobId/cancel');
      _cachedCustomerJobs = null;
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }
}
