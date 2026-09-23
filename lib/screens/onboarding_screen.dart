import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/widgets/onboarding_slide_widget.dart';
import 'package:skillpay/widgets/policy_viewer_modal.dart';
import 'package:skillpay/screens/create_account_screen.dart';
import 'package:skillpay/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _agreedToTerms = false;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Find workers\nnear you.',
      subtitle: 'Discover skilled workers and housekeepers near you.',
      imagePath: 'assets/images/onboarding_workers.png',
    ),
    OnboardingSlide(
      title: 'Safe & secure\npayments.',
      subtitle: 'Payments are held in escrow until the job is done.',
      imagePath: 'assets/images/onboarding_payment.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top logo row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 48,
                    width: 48,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Skillpay',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Page view (takes most of the screen)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return OnboardingSlideWidget(slide: _slides[index]);
                },
              ),
            ),

            // Dot indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: _slides.length,
              effect: const WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                activeDotColor: AppColors.primary,
                dotColor: Color(0xFFDDDDDD),
                spacing: 6,
              ),
            ),

            const SizedBox(height: 20),

            // Terms & Disclaimers Agreement Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppColors.primary,
                      checkColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
                      onChanged: (val) {
                        setState(() {
                          _agreedToTerms = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'I confirm that I have read and accept the ',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: AppColors.textMedium,
                            height: 1.4,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => PolicyViewerModal.show(context, initialType: PolicyType.terms),
                          child: Text(
                            'Terms of Use',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          ', ',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: AppColors.textMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => PolicyViewerModal.show(context, initialType: PolicyType.privacy),
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          ', & ',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: AppColors.textMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => PolicyViewerModal.show(context, initialType: PolicyType.disclaimers),
                          child: Text(
                            'Disclaimers',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          '.',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Create account button
                  ElevatedButton(
                    onPressed: () {
                      if (!_agreedToTerms) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please accept the terms of use and policies to continue.',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: const Color(0xFFD32F2F),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    child: const Text('Create account'),
                  ),

                  const SizedBox(height: 12),

                  // Login button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }
}
