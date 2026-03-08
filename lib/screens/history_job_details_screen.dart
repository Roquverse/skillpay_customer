import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/models/job_model.dart';
import 'package:skillpay/screens/dashboard_screen.dart'; // for capitalize extension

class HistoryJobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const HistoryJobDetailsScreen({super.key, required this.job});

  @override
  State<HistoryJobDetailsScreen> createState() => _HistoryJobDetailsScreenState();
}

class _HistoryJobDetailsScreenState extends State<HistoryJobDetailsScreen> {
  // 0 for Job Details, 1 for Track Progress
  int _selectedTabIndex = 0; 

  @override
  Widget build(BuildContext context) {
    // Generate derived values for UI
    final String shortId = widget.job.id.split('-').first.toUpperCase();
    final String artisanName = widget.job.artisanId != null ? 'Assigned' : 'Searching';
    final String createdDate = "${widget.job.createdAt.month}/${widget.job.createdAt.day}/${widget.job.createdAt.year}";
    final String status = widget.job.status.capitalize();
    
    // Status color mapping based on mockups
    Color tagColor = const Color(0xFFFFF3E0);
    Color tagTextColor = const Color(0xFFEF6C00);
    
    if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'accepted') {
      tagColor = const Color(0xFFE8F5E9);
      tagTextColor = const Color(0xFF2E7D32);
    } else if (status.toLowerCase() == 'canceled' || status.toLowerCase() == 'rejected') {
      tagColor = const Color(0xFFFFEEEE);
      tagTextColor = const Color(0xFFD32F2F);
    }

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
          'Job Details',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JOB-$shortId',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tagTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        artisanName,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '  |  $createdDate',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- Financials Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFinancialCard('Total Cost', '\$${(widget.job.budget / 1000).toStringAsFixed(0)}k'),
                      _buildFinancialCard('Prepayment', '\$${(widget.job.budget * 0.5 / 1000).toStringAsFixed(0)}k'), // Mocking 50% prepay
                      _buildFinancialCard('Balance', '\$${(widget.job.budget * 0.5 / 1000).toStringAsFixed(0)}k', isBold: false),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- Custom Tab Bar ---
                  Row(
                    children: [
                      _buildTab(0, 'Jobs Details'),
                      const SizedBox(width: 24),
                      _buildTab(1, 'Track Progress'),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // --- Tab Content ---
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _selectedTabIndex == 0 ? _buildJobDetailsTab() : _buildTrackProgressTab(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFinancialCard(String title, String value, {bool isBold = true}) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48 - 16) / 3, // Screen width minus padding minus gaps divided by 3
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textDark : AppColors.textMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Service Type', widget.job.category),
        _buildDetailRow('Job Timeline', widget.job.timeline),
        _buildDetailRow('Urgency Type', 'High priority'), // Hardcoded in mockup, could be mapped or added later
        _buildDetailRow('Location', widget.job.location),
        _buildDetailRow('File Upload', 'None'),
        _buildDetailRow('Additional Details', widget.job.description),
        
        const Spacer(),
        
        // --- Action Buttons ---
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Message',
                backgroundColor: AppColors.textDark,
                textColor: Colors.white,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Approve Job',
                backgroundColor: AppColors.primary,
                textColor: AppColors.textDark,
                onTap: () => _showApproveJobDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            label: 'Pay Invoice',
            backgroundColor: const Color(0xFF388E3C), // Green
            textColor: Colors.white,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackProgressTab() {
    return Column(
      children: [
        _buildTimelineItem(
          title: 'Equipment Purchase',
          amount: '\$200k',
          isCompleted: true,
          date: 'Nov 20, 2024',
          isLast: false,
        ),
        _buildTimelineItem(
          title: 'Payment Milestone',
          amount: '\$200k',
          isCompleted: false,
          date: 'Nov 26, 2024',
          tag: 'Pending',
          actionText: 'Pay Invoice',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String amount,
    required bool isCompleted,
    required String date,
    String? tag,
    String? actionText,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column for Line and Dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: AppColors.textDark)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const SizedBox(height: 24), // spacing after last dot
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Right Column for Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32), // Space between items
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '$amount • ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Paid', // Keeping it static for now as mockups imply context
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMedium),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFEF6C00),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (actionText != null) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        actionText,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showApproveJobDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approve Job',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to confirm that this job as been fully completed and you are satisfied with the job done?',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This action means that the artisan is paid completely.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Logic to confirm approval goes here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Project complete confirmed',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
