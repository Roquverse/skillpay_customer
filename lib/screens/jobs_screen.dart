import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/widgets/job_card.dart';
import 'package:skillpay/screens/create_job_screen.dart';
import 'package:skillpay/services/jobs_service.dart';
import 'package:skillpay/models/job_model.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobsService _jobsService = JobsService();
  late Future<List<JobModel>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _refreshJobs();
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = _jobsService.fetchCustomerJobs();
    });
  }

  void _onCreateNew() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateJobScreen()),
    );
    
    // Refresh jobs if a new job was created
    if (result == true) {
      _refreshJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Jobs',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<JobModel>>(
            future: _jobsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading jobs\n${snapshot.error}', textAlign: TextAlign.center),
                );
              }

              final jobs = snapshot.data ?? [];

              if (jobs.isEmpty) {
                return _buildEmptyState();
              }

              return _buildListState(jobs);
            },
          ),
          
          // Sticky Bottom Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 130, // Increased further to avoid intersecting with the floating nav bar
            child: ElevatedButton(
              onPressed: _onCreateNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black, // Dark text like mockup
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Create new',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_center_outlined,
              size: 48,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Jobs Created',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no jobs created yet',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 80), // Space for sticky bottom button
        ],
      ),
    );
  }

  Widget _buildListState(List<JobModel> jobs) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // extra padding for bottom button
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: JobCard(
            title: job.title,
            budget: '\$${job.budget.toStringAsFixed(2)}',
            tags: [job.category],
            location: job.location,
            description: job.description,
            jobId: job.id.split('-').first.toUpperCase(), // Mocking short ID
            proposalCount: job.proposalCount,
            status: job.status,
          ),
        );
      },
    );
  }
}

