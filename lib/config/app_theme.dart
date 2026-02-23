import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Soft & Professional Pastel Palette
  static const Color girlPink = Color(0xFFFFD1DC); // Soft pastel pink
  static const Color boyBlue = Color(0xFFB9E2FA); // Soft pastel blue
  static const Color unisexGreen = Color.fromARGB(
    255,
    173,
    130,
    246,
  ); // Soft pastel mint (Brand color)
  static const Color unisexYellow = Color(0xFFFFF9C4); // Soft pastel yellow

  static const Color primaryGreen = unisexGreen;
  static const Color primaryDark = Color(0xFF475569); // Softer Slate
  static const Color primaryMedium = Color(
    0xFF64748B,
  ); // Medium Slate for secondary text
  static const Color backgroundSoft = Color(0xFFF8FAFC); // Very light gray/blue
  static const Color surfaceWhite = Colors.white;

  // Pastel Accents
  static const Color pastelPink = girlPink;
  static const Color pastelPeach = Color(0xFFFFF0E0);
  static const Color pastelYellow = unisexYellow;
  static const Color pastelGreen = Color(0xFFE8F6F1);
  static const Color pastelBlue = boyBlue;
  static const Color pastelLavender = Color(0xFFF3E5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: surfaceWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: primaryDark,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        surfaceContainerHighest: backgroundSoft,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: primaryDark,
          height: 1.1,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: primaryDark,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primaryDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: primaryDark.withValues(alpha: 0.8),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: primaryDark.withValues(alpha: 0.7),
          height: 1.5,
        ),
        labelLarge: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryDark),
        titleTextStyle: TextStyle(
          color: primaryDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: BorderSide(
            color: primaryMedium.withValues(alpha: 0.2),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: TextStyle(color: primaryDark.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surfaceWhite,
      ),
    );
  }
}
