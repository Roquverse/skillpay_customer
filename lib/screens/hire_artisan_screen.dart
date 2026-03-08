import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/screens/pay_invoice_modal.dart';

import 'package:skillpay/services/jobs_service.dart';
import 'package:skillpay/models/job_model.dart';
import 'package:skillpay/screens/create_job_screen.dart';

class HireArtisanScreen extends StatefulWidget {
  final Map<String, dynamic> artisanData;

  const HireArtisanScreen({
    super.key,
    required this.artisanData,
  });

  @override
  State<HireArtisanScreen> createState() => _HireArtisanScreenState();
}

class _HireArtisanScreenState extends State<HireArtisanScreen> {
  JobModel? _selectedJob;
  
  final JobsService _jobsService = JobsService();
  late Future<List<JobModel>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _jobsService.fetchCustomerJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hire ${widget.artisanData['name'] ?? 'Artisan'}',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What job do you want to hire for?',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Dynamic Job Dropdown
                _buildDynamicJobDropdown(),
                
                const SizedBox(height: 24),
                
                // Job Details Card (Only show if a job is selected)
                if (_selectedJob != null) _buildJobDetailsCard(),
                
                const SizedBox(height: 100), // Padding for sticky bottom nav
              ],
            ),
          ),
          
          // Sticky Bottom Actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateJobScreen()),
                        );
                        if (result == true) {
                          setState(() {
                            _selectedJob = null;
                            _jobsFuture = _jobsService.fetchCustomerJobs();
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5), // Light grey background
                        foregroundColor: AppColors.textDark,
                        side: BorderSide.none, // No border for 'Create job' based on mockup
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create job',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedJob != null
                          ? () {
                              showPayInvoiceModal(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hire',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicJobDropdown() {
    return FutureBuilder<List<JobModel>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loading jobs...'),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          );
        }

        final jobs = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<JobModel>(
              value: _selectedJob,
              hint: Text(
                jobs.isEmpty ? 'No jobs available' : 'Select a job',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: jobs.isEmpty ? Colors.red : const Color(0xFFBDBDBD),
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              onChanged: jobs.isEmpty ? null : (JobModel? newValue) {
                setState(() {
                  _selectedJob = newValue;
                });
              },
              items: jobs.map<DropdownMenuItem<JobModel>>((JobModel job) {
                return DropdownMenuItem<JobModel>(
                  value: job,
                  child: Text(job.title),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Very light grey bg for card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedJob?.title ?? '',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Amount: ',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
              Text(
                '\$${_selectedJob?.budget.toStringAsFixed(2) ?? '0.00'}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50), // Green amount
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Dynamic Badges
          Row(
            children: [_selectedJob?.category ?? 'General'].map((badge) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textMedium, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedJob?.location ?? 'Location not provided',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bio/Description
          Text(
            _selectedJob?.description ?? 'No description provided.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Footer Details
          Text(
            'Job ID: ${_selectedJob?.id.split('-').first.toUpperCase() ?? 'N/A'}  •  Proposal: ${_selectedJob?.proposalCount ?? 0}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
