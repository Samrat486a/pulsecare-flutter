import 'package:flutter/material.dart';

class AppTheme {
  // Executive Clinical Palette (Deep Obsidian, Royal Sapphire, Surgical Teal & Emerald)
  static const Color brandDark = Color(0xFF090D16); // Deep Obsidian
  static const Color brandNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryColor = Color(0xFF1D4ED8); // Executive Royal Cobalt
  static const Color primaryDark = Color(0xFF1E3A8A); // Deep Navy Blue
  static const Color primaryLight = Color(0xFFEFF6FF); // Soft Cobalt Tint
  
  static const Color secondaryColor = Color(0xFF0D9488); // Surgical Teal
  static const Color secondaryLight = Color(0xFFF0FDFA);
  
  static const Color accentColor = Color(0xFFD97706); // Warm Clinical Gold
  static const Color accentLight = Color(0xFFFEF3C7);
  
  static const Color successColor = Color(0xFF059669); // Biometric Emerald
  static const Color successLight = Color(0xFFECFDF5);
  
  static const Color errorColor = Color(0xFFDC2626); // Emergency Crimson
  static const Color errorLight = Color(0xFFFEF2F2);
  
  static const Color backgroundColor = Color(0xFFF8FAFC); // Clean Canvas
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  
  static const Color textPrimary = Color(0xFF0A0F1D); // Obsidian Text
  static const Color textSecondary = Color(0xFF475569); // Slate Subtext
  static const Color textMuted = Color(0xFF94A3B8); // Muted Details
  static const Color borderColor = Color(0xFFE2E8F0); // Architectural Hairline
  static const Color borderFocused = Color(0xFF2563EB);

  // Performance-optimized low-end hardware safe shadows (0 expensive Gaussian passes)
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x040F172A),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        const BoxShadow(
          color: Color(0x181D4ED8),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        const BoxShadow(
          color: Color(0x060F172A),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: borderColor, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.8),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
