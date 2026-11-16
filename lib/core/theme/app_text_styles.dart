import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle headlineLarge({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.25,
      );

  static TextStyle headlineMedium({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle headlineSmall({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.35,
      );

  // Body Text
  static TextStyle bodyLarge({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle bodyMedium({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        height: 1.4,
      );

  static TextStyle bodySmall({bool isDark = false}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        height: 1.4,
      );

  // Financial Figures & Numbers
  static TextStyle financialLarge({required Color color}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      );

  static TextStyle financialMedium({required Color color}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.25,
      );

  static TextStyle financialSmall({required Color color}) =>
      GoogleFonts.hindSiliguri(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Button Labels
  static TextStyle buttonText = GoogleFonts.hindSiliguri(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
