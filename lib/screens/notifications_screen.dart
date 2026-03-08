import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  // Toggle this boolean to see the empty state vs populated state
  final bool _isEmpty = false;

  const NotificationsScreen({super.key});

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
          'Notification',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _isEmpty ? _buildEmptyState() : _buildPopulatedState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 40,
                  color: AppColors.textMedium,
                ),
                Positioned(
                  top: 22,
                  right: 24,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Notification Empty',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no recent notification',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        _buildNotificationCard(
          icon: Icons.attach_money_rounded,
          richText: TextSpan(
            text: 'Your account have been credited with ',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            children: [
              TextSpan(
                text: '\$450',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' click to see details...'),
            ],
          ),
          timeText: 'Today 10:49 AM',
          hasRedDot: true,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.work_outline_rounded,
          richText: TextSpan(
            text: 'New job proposal from ',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            children: [
              TextSpan(
                text: 'Mathew Kent',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' click to see details...'),
            ],
          ),
          timeText: 'Today 10:49 AM',
          hasRedDot: true,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.notifications_none_rounded,
          richText: TextSpan(
            text: 'New update on job ',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            children: [
              TextSpan(
                text: '1738884049',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: '\nclick to see more details...'),
            ],
          ),
          timeText: 'Today 10:49 AM',
          hasRedDot: true,
        ),
        const SizedBox(height: 16),
        // Duplicated items from mockup to show scrolling
        _buildNotificationCard(
          icon: Icons.attach_money_rounded,
          richText: TextSpan(
            text: 'Your account have been credited with ',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            children: [
              TextSpan(
                text: '\$450',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' click to see details...'),
            ],
          ),
          timeText: 'Today 10:49 AM',
          hasRedDot: false,
        ),
        const SizedBox(height: 16),
        _buildNotificationCard(
          icon: Icons.work_outline_rounded,
          richText: TextSpan(
            text: 'New job proposal from ',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            children: [
              TextSpan(
                text: 'Mathew Kent',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' click to see details...'),
            ],
          ),
          timeText: 'Today 10:49 AM',
          hasRedDot: false,
        ),
      ],
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required TextSpan richText,
    required String timeText,
    required bool hasRedDot,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.textDark, size: 20),
                    ),
                    if (hasRedDot)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: RichText(
                      text: richText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                Text(
                  'View',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
