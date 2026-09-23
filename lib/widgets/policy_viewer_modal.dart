import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';

enum PolicyType { terms, privacy, disclaimers }

class PolicyViewerModal extends StatefulWidget {
  final PolicyType initialType;

  const PolicyViewerModal({super.key, this.initialType = PolicyType.terms});

  static Future<void> show(BuildContext context, {PolicyType initialType = PolicyType.terms}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PolicyViewerModal(initialType: initialType),
    );
  }

  @override
  State<PolicyViewerModal> createState() => _PolicyViewerModalState();
}

class _PolicyViewerModalState extends State<PolicyViewerModal> {
  late PolicyType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Legal & Policies',
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDark),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Policy Type Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTab('Terms', PolicyType.terms),
                  _buildTab('Privacy', PolicyType.privacy),
                  _buildTab('Disclaimers', PolicyType.disclaimers),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Policy Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: _buildContent(),
            ),
          ),

          // Bottom Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                ),
                child: Text(
                  'I Understand',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, PolicyType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textDark : AppColors.textMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedType) {
      case PolicyType.terms:
        return _buildTermsContent();
      case PolicyType.privacy:
        return _buildPrivacyContent();
      case PolicyType.disclaimers:
        return _buildDisclaimersContent();
    }
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Terms of Service',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: September 2026',
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 16),
        _buildSection(
          '1. Acceptance of Terms',
          'By accessing, registering for, or using the SkillPay Customer Application, you agree to be bound by these Terms of Service. If you do not agree to these terms, do not access or use the application.',
        ),
        _buildSection(
          '2. The SkillPay Marketplace',
          'SkillPay operates as an independent peer-to-peer technology platform connecting homeowners and customers with independent skilled workers, artisans, and contractors. SkillPay does not directly provide maintenance, construction, or artisan services.',
        ),
        _buildSection(
          '3. Escrow Payments & Protection',
          'To safeguard customer transactions, payments for booked services are held securely in escrow. Funds are only released to the artisan once you confirm job completion or upon expiration of the dispute inspection window.',
        ),
        _buildSection(
          '4. Cancellations & Refunds',
          'Cancellations prior to work commencement are eligible for full or partial refunds according to the artisan cancellation policy. Once service work has commenced, dispute resolution procedures govern release of funds.',
        ),
        _buildSection(
          '5. Code of Conduct',
          'Customers must maintain respectful and lawful interactions with artisans. Discriminatory, abusive, fraudulent, or harassing conduct will result in immediate account termination.',
        ),
        _buildSection(
          '6. Dispute Resolution',
          'In the event of defective workmanship or non-delivery of agreed services, customers must submit a dispute through the app within 48 hours of job mark-off.',
        ),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Privacy Policy',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: September 2026',
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 16),
        _buildSection(
          '1. Information We Collect',
          'We collect information you provide directly, including your name, email address, phone number, physical address/location for service delivery, and payment authorization details.',
        ),
        _buildSection(
          '2. Geolocation Information',
          'With your permission, we use approximate and precise location data to match you with nearby artisans, calculate travel distance, and coordinate on-site job appointments.',
        ),
        _buildSection(
          '3. Payment Information Security',
          'Payment card details are tokenized and processed securely by regulated payment partners (Stripe / Paystack). SkillPay does not store full credit card numbers or sensitive CVVs on our servers.',
        ),
        _buildSection(
          '4. Communications',
          'Chat messages exchanged with artisans through the SkillPay app are stored to facilitate project collaboration and mediate warranty or service quality disputes.',
        ),
        _buildSection(
          '5. Your Rights',
          'You may request access to, correction of, or deactivation of your personal data at any time via the Settings screen or by contacting privacy@skillpay.com.',
        ),
      ],
    );
  }

  Widget _buildDisclaimersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community & Legal Disclaimers',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: September 2026',
          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
        ),
        const SizedBox(height: 16),
        _buildSection(
          '1. Independent Contractor Disclaimer',
          'Artisans, tradespersons, and technicians on SkillPay are independent third-party service providers, not employees or agents of SkillPay. SkillPay makes no direct guarantees regarding the punctuality or perfection of individual tradespersons beyond our escrow protection rules.',
        ),
        _buildSection(
          '2. Verification Disclosure',
          'While SkillPay performs identity verification and reviews qualifications, customers are encouraged to verify credentials and supervise all on-site home activities.',
        ),
        _buildSection(
          '3. Limitation of Liability',
          'To the fullest extent permitted by applicable law, SkillPay shall not be liable for indirect, punitive, or consequential damages resulting from third-party services booked via the platform.',
        ),
      ],
    );
  }
}
