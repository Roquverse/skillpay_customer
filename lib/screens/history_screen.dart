import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/services/jobs_service.dart';
import 'package:skillpay/models/job_model.dart';
import 'package:skillpay/screens/dashboard_screen.dart'; // for capitalize extension
import 'package:skillpay/screens/history_job_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final JobsService _jobsService = JobsService();
  late Future<List<JobModel>> _jobsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jobsFuture = _jobsService.fetchCustomerJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background per mockups
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'History',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: FutureBuilder<List<JobModel>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading history\n${snapshot.error}', textAlign: TextAlign.center));
                }

                final allJobs = snapshot.data ?? [];
                
                // Filter to only show past/completed jobs in History
                final jobs = allJobs.where((job) {
                  final status = job.status.toLowerCase();
                  return ['completed', 'canceled', 'rejected', 'failed'].contains(status);
                }).toList();

                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      'No jobs history found.',
                      style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100), // padding for bottom nav
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildHistoryCard(job);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: GoogleFonts.outfit(
                  color: const Color(0xFFB0B0B0),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textDark,
              ),
              onChanged: (value) {
                // Implement local search filtering if needed later
              },
            ),
          ),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B0B0),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(JobModel job) {
    // Determine mapping based on mockup
    final String shortId = job.id.split('-').first.toUpperCase();
    final String artisanName = job.artisanId != null ? 'Assigned' : 'Searching';
    final String tradeName = job.category;
    final String status = job.status.capitalize();
    
    // Status color mapping based on mockups
    Color tagColor;
    Color tagTextColor;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'accepted': // if accepted means it's running but we use custom states
        tagColor = const Color(0xFFE8F5E9); // Light Green
        tagTextColor = const Color(0xFF2E7D32); // Dark Green
        break;
      case 'in progress':
        tagColor = const Color(0xFFFFF3E0); // Light Orange
        tagTextColor = const Color(0xFFEF6C00); // Orange
        break;
      case 'canceled':
      case 'rejected':
      case 'failed':
        tagColor = const Color(0xFFFFEEEE); // Light Red
        tagTextColor = const Color(0xFFD32F2F); // Red
        break;
      case 'pending':
      default:
        tagColor = const Color(0xFFFFF3E0); // Light Orange
        tagTextColor = const Color(0xFFEF6C00); // Orange
        break;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryJobDetailsScreen(job: job),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.work_outline_rounded,
                      color: AppColors.textDark, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'JOB-$shortId',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$artisanName  |  $tradeName',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: tagTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }
}
