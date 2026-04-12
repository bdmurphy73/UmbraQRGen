import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme _buildTextTheme(
    TextTheme base,
    Color textColor,
    Color secondaryColor,
  ) {
    final montserrat = GoogleFonts.montserratTextTheme(base);
    return montserrat.copyWith(
      titleLarge: montserrat.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.33,
      ),
      titleMedium: montserrat.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: montserrat.titleSmall?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyLarge: montserrat.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: montserrat.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: montserrat.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.33,
        letterSpacing: 0.4,
      ),
      labelLarge: montserrat.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.43,
        letterSpacing: 1.25,
      ),
      labelMedium: montserrat.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.33,
        letterSpacing: 0.5,
      ),
    );
  }

  static TextTheme darkTextTheme = _buildTextTheme(
    const TextTheme(),
    AppColors.iceBlue,
    AppColors.mutedIce,
  );

  static TextTheme lightTextTheme = _buildTextTheme(
    const TextTheme(),
    AppColors.lightText,
    AppColors.lightTextSecondary,
  );
}
