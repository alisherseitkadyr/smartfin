import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand and status colors.
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
  static const blueDark = Color(0xFF2563EB);
  static const indigoLight = Color(0xFFEEF2FF);
  static const indigoDark = Color(0xFF1D4ED8);
  static const greenDeep = Color(0xFF0F4C2A);
  static const amberMid = Color(0xFFD97706);
  static const amberDark = Color(0xFF92400E);

  // Light theme neutrals.
  static const bg = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF6B7280);
  static const mutedLight = Color(0xFFE5E7EB);
  static const mutedXLight = Color(0xFFF9FAFB);
  static const text = Color(0xFF111827);
  static const text2 = Color(0xFF374151);

  // Dark theme neutrals.
  static const bgDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1D27);
  static const mutedDark = Color(0xFF9CA3AF);
  static const mutedLightDark = Color(0xFF374151);
  static const mutedXLightDark = Color(0xFF1F2937);
  static const textDark = Color(0xFFFFFFFF);
  static const textDark2 = Color(0xFFD1D5DB);
  static const highlightBorder = Color(0xFFFCD34D);
  static const highlightBorderDark = Color(0xFF92400E);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getTextColor(BuildContext context) =>
      isDark(context) ? textDark : text;

  static Color getTextColor2(BuildContext context) =>
      isDark(context) ? textDark2 : text2;

  static Color getMutedColor(BuildContext context) =>
      isDark(context) ? mutedDark : muted;

  static Color getMutedLightColor(BuildContext context) =>
      isDark(context) ? mutedLightDark : mutedLight;

  static Color getMutedXLightColor(BuildContext context) =>
      isDark(context) ? mutedXLightDark : mutedXLight;

  static Color getBgColor(BuildContext context) => isDark(context) ? bgDark : bg;

  static Color getSurfaceColor(BuildContext context) =>
      isDark(context) ? surfaceDark : surface;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(_ThemePalette.light);

  static ThemeData get dark => _buildTheme(_ThemePalette.dark);

  static ThemeData _buildTheme(_ThemePalette colors) {
    final base = colors.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        brightness: colors.brightness,
        seedColor: AppColors.green,
        primary: AppColors.green,
        secondary: AppColors.navy,
        surface: colors.surface,
        error: AppColors.red,
      ),
      textTheme: _buildTextTheme(base.textTheme, colors),
      appBarTheme: _buildAppBarTheme(colors),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(colors),
      cardTheme: _buildCardTheme(colors),
      inputDecorationTheme: _buildInputDecorationTheme(colors),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, _ThemePalette colors) {
    return GoogleFonts.soraTextTheme(base).copyWith(
      displayMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: colors.text,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.text,
      ),
      headlineMedium: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      headlineSmall: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      titleMedium: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      titleSmall: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: colors.text2,
        height: 1.65,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.text2,
        height: 1.55,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.muted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colors.muted,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.sora(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: colors.muted,
        letterSpacing: 0.5,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme(_ThemePalette colors) {
    return AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: colors.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme(
    _ThemePalette colors,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.isDark ? AppColors.green : AppColors.greenDark,
      unselectedItemColor: colors.muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static CardThemeData _buildCardTheme(_ThemePalette colors) {
    return CardThemeData(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border, width: 1.5),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(_ThemePalette colors) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border, width: 1.5),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colors.subtleSurface,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: colors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greenMid, width: 1.5),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.sora(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        elevation: 0,
      ),
    );
  }
}

class _ThemePalette {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color subtleSurface;
  final Color border;
  final Color text;
  final Color text2;
  final Color muted;

  const _ThemePalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.subtleSurface,
    required this.border,
    required this.text,
    required this.text2,
    required this.muted,
  });

  bool get isDark => brightness == Brightness.dark;

  static const light = _ThemePalette(
    brightness: Brightness.light,
    background: AppColors.bg,
    surface: AppColors.surface,
    subtleSurface: AppColors.mutedXLight,
    border: AppColors.mutedLight,
    text: AppColors.text,
    text2: AppColors.text2,
    muted: AppColors.muted,
  );

  static const dark = _ThemePalette(
    brightness: Brightness.dark,
    background: AppColors.bgDark,
    surface: AppColors.surfaceDark,
    subtleSurface: AppColors.mutedXLightDark,
    border: AppColors.mutedLightDark,
    text: AppColors.textDark,
    text2: AppColors.textDark2,
    muted: AppColors.mutedDark,
  );
}

extension AppThemeColors on BuildContext {
  Color get mutedLight => AppColors.getMutedLightColor(this);

  Color get mutedXLight => AppColors.getMutedXLightColor(this);

  Color get textColor => AppColors.getTextColor(this);

  Color get text2Color => AppColors.getTextColor2(this);

  Color get mutedColor => AppColors.getMutedColor(this);

  Color get borderColor => AppColors.getMutedLightColor(this);

  Color get subtleBgColor =>
      AppColors.isDark(this) ? AppColors.mutedXLightDark : AppColors.amberLight;

  Color get subtleBorderColor => AppColors.isDark(this)
      ? AppColors.highlightBorderDark
      : AppColors.highlightBorder;
}
