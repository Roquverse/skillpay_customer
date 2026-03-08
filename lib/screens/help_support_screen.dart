import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Text(
            'How can we help you?',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSupportOption(
            context: context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Live Chat',
            subtitle: 'Start a conversation with our team',
            onTap: () {
              // Future: Open live chat provider
            },
          ),
          
          _buildSupportOption(
            context: context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@skillpay.com',
            onTap: () {
              // Future: Launch email client
            },
          ),
          
          _buildSupportOption(
            context: context,
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+1 (800) 123-4567',
            onTap: () {
              // Future: Launch phone dialer
            },
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          _FaqAccordion(
            question: 'How do I hire an artisan?',
            answer: 'To hire an artisan, browse the available categories or search for a specific skill. Review their profile, read reviews, and click "Hire" to send them a job proposal. You can also create a job first and invite artisans to it.',
          ),
          _FaqAccordion(
            question: 'How does the payment system work?',
            answer: 'We hold your payment securely in escrow until the job is completed to your satisfaction. Once you approve the work, the funds are released to the artisan. This protects both you and the worker.',
          ),
          _FaqAccordion(
            question: 'What if I am not satisfied with the work?',
            answer: 'If you are unsatisfied, you can raise a dispute before releasing the payment. Our support team will mediate the situation, review the evidence, and determine the appropriate resolution or refund.',
          ),
          _FaqAccordion(
            question: 'How do I reset my password?',
            answer: 'Go to the login screen and tap on "Forgot Password?". Enter your registered email address, and we will send you a link with instructions to securely reset your password.',
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.textDark, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMedium, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqAccordion({required this.question, required this.answer});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(vertical: 4),
          title: Text(
            widget.question,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.remove : Icons.add,
            color: AppColors.textDark,
            size: 24,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Text(
                widget.answer,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
