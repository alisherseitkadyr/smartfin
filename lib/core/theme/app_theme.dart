import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary colors (universal)
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

  // Light theme colors
  static const bg = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B7280);
  static const mutedLight = Color(0xFFE5E7EB);
  static const mutedXLight = Color(0xFFF9FAFB);
  static const text = Color(0xFF111827);
  static const text2 = Color(0xFF374151);

  // Dark theme colors
  static const bgDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1D27);
  static const mutedDark = Color(0xFF9CA3AF);
  static const mutedLightDark = Color(0xFF374151);
  static const mutedXLightDark = Color(0xFF1F2937);
  static const textDark = Color(0xFFFFFFFF);
  static const textDark2 = Color(0xFFD1D5DB);

  // Helper function to get dynamic colors based on brightness
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textDark : text;
  }

  static Color getTextColor2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? textDark2 : text2;
  }

  static Color getMutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? mutedDark : muted;
  }

  static Color getMutedLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? mutedLightDark : mutedLight;
  }

  static Color getMutedXLightColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? mutedXLightDark : mutedXLight;
  }

  static Color getBgColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bgDark : bg;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceDark : surface;
  }
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


  // Add inside AppTheme class:
static ThemeData get dark {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0F1117),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.navy,
      surface: const Color(0xFF1A1D27),
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.soraTextTheme(base.textTheme).copyWith(
      displayMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
      headlineLarge: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      headlineSmall: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB), height: 1.65),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB), height: 1.55),
      bodySmall: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF), height: 1.4),
      labelLarge: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF9CA3AF), letterSpacing: 0.5),
      labelSmall: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF9CA3AF), letterSpacing: 0.5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A1D27),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1D27),
      selectedItemColor: AppColors.green,
      unselectedItemColor: const Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1D27),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF374151), width: 1.5),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F2937),
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFF6B7280)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF374151), width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF374151), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF374151), thickness: 1, space: 1),
  );
}
}

/// Extension to access theme-aware colors
extension AppThemeColors on BuildContext {
  /// Get the muted light color that adapts to the theme
  Color get mutedLight {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF374151)
        : AppColors.mutedLight;
  }

  /// Get the muted extra light color that adapts to the theme
  Color get mutedXLight {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF1F2937)
        : AppColors.mutedXLight;
  }

  /// Get the text color that adapts to the theme
  Color get textColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? Colors.white : AppColors.text;
  }

  /// Get the text2 color that adapts to the theme
  Color get text2Color {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFFD1D5DB)
        : AppColors.text2;
  }

  /// Get the muted color that adapts to the theme
  Color get mutedColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF9CA3AF)
        : AppColors.muted;
  }

  /// Get the border color that adapts to the theme
  Color get borderColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF374151)
        : AppColors.mutedLight;
  }

  /// Get the subtle background color that adapts to the theme
  Color get subtleBgColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF1F2937)
        : const Color(0xFFFEF3C7);
  }

  /// Get the subtle border color for highlighted elements
  Color get subtleBorderColor {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF92400E)
        : const Color(0xFFFCD34D);
  }
}
