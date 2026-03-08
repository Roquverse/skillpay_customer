import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/widgets/auth_widgets.dart'; // Reusing text field styles

import 'package:skillpay/services/jobs_service.dart';
import 'package:skillpay/models/job_model.dart';
import 'package:uuid/uuid.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailsController = TextEditingController();
  final _budgetController = TextEditingController();
  final JobsService _jobsService = JobsService();
  
  String? _selectedCategory;
  String? _selectedTimeline;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _detailsController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _onCreateJob() async {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out the title and budget')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final job = JobModel(
        id: const Uuid().v4(), // Generate temporary ID, Supabase will generate a real one but we need it for the model
        title: _titleController.text.trim(),
        description: _detailsController.text.trim(),
        category: _selectedCategory ?? 'General',
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Location not provided',
        budget: double.tryParse(_budgetController.text.replaceAll('\$', '').trim()) ?? 0.0,
        timeline: _selectedTimeline ?? 'Flexible',
        status: 'pending',
        proposalCount: 0,
        customerId: '', // Set by the service
        createdAt: DateTime.now(),
      );

      await _jobsService.createJob(job);
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating job: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Create Job',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Job Tittle'),
            buildAuthTextField(
              controller: _titleController,
              hint: 'Enter job tittle',
            ),
            const SizedBox(height: 20),

            _buildLabel('Job Category'),
            _buildDropdown(
              hint: 'Select',
              value: _selectedCategory,
              items: ['Plumbing', 'Electrical', 'Cleaning', 'Engineering'],
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Location'),
                Text(
                  'Saved address',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            buildAuthTextField(
              controller: _locationController,
              hint: 'Enter address',
            ),
            const SizedBox(height: 20),

            _buildLabel('Additional Details'),
            TextFormField(
              controller: _detailsController,
              maxLines: 4,
              style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Enter description',
                hintStyle: GoogleFonts.outfit(fontSize: 15, color: AppColors.textLight),
                filled: true,
                fillColor: const Color(0xFFF9F9F9),
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('File upload'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to upload file',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Job Timeline'),
            _buildDropdown(
              hint: 'Select timeline',
              value: _selectedTimeline,
              items: ['1 Week', '2 Weeks', '1 Month', '3 Months'],
              onChanged: (val) => setState(() => _selectedTimeline = val),
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 20),

            _buildLabel('Budget'),
            buildAuthTextField(
              controller: _budgetController,
              hint: '\$ 0.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),

            // Fixed bottom create button (part of scroll view here as per UI flow, but could be sticky)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onCreateJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                      )
                    : Text(
                        'Create job',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textLight),
          ),
          icon: Icon(icon ?? Icons.keyboard_arrow_down_rounded, color: AppColors.textMedium),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textDark)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
