import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';

/// Shared back button used across all auth screens.
Widget buildAuthBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppColors.textDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}

/// Animated primary button that dims when [enabled] is false.
Widget buildAuthPrimaryButton({
  required String label,
  required bool enabled,
  required VoidCallback onTap,
  bool isLoading = false,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: double.infinity,
    height: 52,
    decoration: BoxDecoration(
      color: enabled ? AppColors.primary : AppColors.primary.withAlpha(100),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled && !isLoading ? onTap : null,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.textDark),
                )
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
        ),
      ),
    ),
  );
}

/// Outlined text field used across auth screens.
Widget buildAuthTextField({
  required TextEditingController controller,
  required String hint,
  IconData? icon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
  Widget? suffix,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: GoogleFonts.outfit(
        fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(
          color: AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w400),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.textLight, size: 18) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: icon != null ? 16 : 24, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
    ),
    validator: validator,
  );
}

/// Bottom Terms & Privacy footer shared across auth screens.
Widget buildAuthFooter() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.outfit(
            fontSize: 11, color: AppColors.textLight, height: 1.5),
        children: [
          const TextSpan(text: 'By logging in, you agree to SkillPay\n'),
          TextSpan(
            text: 'Terms of Service',
            style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline),
          ),
          const TextSpan(text: '  —  '),
          TextSpan(
            text: 'Privacy Policy',
            style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline),
          ),
        ],
      ),
    ),
  );
}

/// Red error banner shown at the bottom of auth screens.
Widget buildAuthErrorBanner(String message) {
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200, width: 1),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
