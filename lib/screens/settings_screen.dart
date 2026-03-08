import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/screens/profile_screen.dart';
import 'package:skillpay/screens/proposals_screen.dart';
import 'package:skillpay/screens/transactions_screen.dart';
import 'package:skillpay/screens/address_screen.dart';
import 'package:skillpay/screens/security_screen.dart';
import 'package:skillpay/screens/help_support_screen.dart';
import 'package:skillpay/screens/about_screen.dart';
import 'package:skillpay/screens/onboarding_screen.dart';
import 'package:skillpay/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // Bottom padding for nav bar
        children: [
          _buildSettingsItem(
            context: context,
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.assignment_outlined,
            title: 'Proposals',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProposalsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.swap_horiz_rounded,
            title: 'Transactions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionsScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Address',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.verified_user_outlined,
            title: 'Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Log out',
            iconColor: Colors.red.shade600,
            textColor: Colors.red.shade600,
            onTap: () async {
              try {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              } catch (e) {
                // handle error if needed
                debugPrint('Logout error: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? AppColors.textDark, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppColors.textDark,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: iconColor ?? AppColors.textDark, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
