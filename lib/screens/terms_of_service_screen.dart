import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Introduction',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to Skillpay. By accessing our application and using our services, you agree to be bound by these Terms of Service. Please read them carefully.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '2. User Responsibilities',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Users are responsible for maintaining the confidentiality of their account credentials. You agree to provide accurate, current, and complete information during the registration process.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '3. Payments and Escrow',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Skillpay facilitates secure transactions between customers and artisans. Funds are held in escrow and released only upon mutual agreement or through our dispute resolution process.',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: AppColors.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
