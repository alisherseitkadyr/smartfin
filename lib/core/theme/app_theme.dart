import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const green = Color(0xFF22C55E);
  static const greenDark = Color(0xFF15803D);
  static const greenLight = Color(0xFFDCFCE7);
  static const greenMid = Color(0xFF86EFAC);
  static const navy = Color(0xFF1E3A5F);
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFEFF6FF);
  static const bg = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B7280);
  static const mutedLight = Color(0xFFE5E7EB);
  static const mutedXLight = Color(0xFFF9FAFB);
  static const text = Color(0xFF111827);
  static const text2 = Color(0xFF374151);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
        secondary: AppColors.navy,
        surface: AppColors.surface,
        error: AppColors.red,
      ),
      textTheme: GoogleFonts.soraTextTheme(base.textTheme).copyWith(
        displayMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.3),
        headlineLarge: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text),
        headlineMedium: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
        headlineSmall: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text),
        titleLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
        titleMedium: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
        titleSmall: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.text2, height: 1.65),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.text2, height: 1.55),
        bodySmall: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.muted, height: 1.4),
        labelLarge: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.5),
        labelSmall: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.greenDark,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.mutedLight, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.mutedXLight,
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mutedLight, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mutedLight, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.mutedLight, thickness: 1, space: 1),
    );
  }
}