import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryLight = Color(0xFF1A1A2E);
  static const Color _primaryDark = Color(0xFFE8E8E8);
  static const Color _backgroundLight = Color(0xFFFAF9F7);
  static const Color _backgroundDark = Color(0xFF0A0A0A);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceDark = Color(0xFF141414);
  static const String _fontFamily = 'Georgia';

  static ThemeData theme(BuildContext context, {required bool isDark}) {
    Size size;
    try {
      size = MediaQuery.sizeOf(context);
    } catch (_) {
      size = const Size(375, 812);
    }

    final sw = size.width;
    final sh = size.height;
    final isTablet = sw > 600;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryLight,
        brightness: brightness,
        primary: isDark ? _primaryDark : _primaryLight,
        surface: isDark ? _surfaceDark : _surfaceLight,
      ),
      scaffoldBackgroundColor:
          isDark ? _backgroundDark : _backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? _backgroundDark : _backgroundLight,
        scrolledUnderElevation: 0,
        toolbarHeight: sh * 0.08,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: isTablet ? sw * 0.05 : sw * 0.06,
          fontWeight: FontWeight.bold,
          color: isDark ? _primaryDark : _primaryLight,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.01,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: isTablet ? sw * 0.07 : sw * 0.08,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontSize: isTablet ? sw * 0.035 : sw * 0.045,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: isTablet ? sw * 0.03 : sw * 0.04,
          color: isDark
              ? const Color(0xFFCCCCCC)
              : const Color(0xFF444444),
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Helvetica',
          fontSize: isTablet ? sw * 0.02 : sw * 0.028,
          color: const Color(0xFF888888),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF0EEE9),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.015,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sw * 0.03),
          borderSide: BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        selectedColor: isDark ? _primaryDark : _primaryLight,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.02,
          vertical: sh * 0.005,
        ),
        labelStyle: TextStyle(
          fontSize: isTablet ? sw * 0.025 : sw * 0.032,
          fontWeight: FontWeight.w500,
          color: isDark ? _primaryDark : _primaryLight,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: isTablet ? sw * 0.025 : sw * 0.032,
          fontWeight: FontWeight.bold,
          color: isDark ? _backgroundDark : Colors.white,
        ),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
          width: sw * 0.002,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sw * 0.05),
        ),
        showCheckmark: false,
      ),
    );
  }

  static ButtonStyle primaryButtonStyle(
      BuildContext context, double sw, double sh) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: isDark ? Colors.white : Colors.black,
      foregroundColor: isDark ? Colors.black : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.08,
        vertical: sh * 0.015,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      textStyle: TextStyle(
        fontSize: sw * 0.04,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      overlayColor: isDark
          ? Colors.black.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.1),
    );
  }
}