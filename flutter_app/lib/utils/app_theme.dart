import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  // Stitch Design Colors
  // Light Mode
  static const Color primary = Color(0xFF2C097F); // Future Dusk
  static const Color primaryLight = Color(0xFF4B1E99);
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6E6DB);
  
  // Dark Mode
  static const Color primaryDark = Color(0xFFE0DC05); // Lime Accent
  static const Color backgroundDark = Color(0xFF151022); // Deep Purple Black
  static const Color surfaceDark = Color(0xFF2C2B1B);
  static const Color borderDark = Color(0xFF333220);

  // Text
  static const Color textMainLight = Color(0xFF181811);
  static const Color textMutedLight = Color(0xFF8C8B5F);
  
  static const Color textMainDark = Color(0xFFF2F2E8);
  static const Color textMutedDark = Color(0xFFAFAFA0);

  // Status Colors (Shared)
  static const Color statusStart = Color(0xFF60A5FA);
  static const Color statusExec = Color(0xFFFBBF24);
  static const Color statusDone = Color(0xFF34D399);

  // Text Styles
  static TextStyle get display => GoogleFonts.splineSans(
    fontWeight: FontWeight.bold,
  );

  static TextStyle get body => GoogleFonts.splineSans();
  
  static TextStyle get bodyKr => GoogleFonts.notoSansKr();

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSurface: textMainLight,
        outline: borderLight,
        surfaceContainerHighest: backgroundLight,
      ),
      textTheme: GoogleFonts.splineSansTextTheme().apply(
        bodyColor: textMainLight,
        displayColor: textMainLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textMainLight),
        titleTextStyle: TextStyle(
          color: textMainLight,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16),
           borderSide: const BorderSide(color: Color(0x0D000000)), // black/5
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16),
           borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: TextStyle(color: textMainLight.withValues(alpha: 0.4)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: primaryDark, // Use Lime as secondary too in dark mode
        surface: surfaceDark, // #2c2b1b
        onSurface: textMainDark, 
        onPrimary: backgroundDark, // Text on Lime should be dark
        outline: borderDark,
        surfaceContainerHighest: surfaceDark,
      ),
      textTheme: GoogleFonts.splineSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMainDark,
        displayColor: textMainDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textMainDark),
        titleTextStyle: TextStyle(
          color: textMainDark,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16),
           borderSide: const BorderSide(color: Color(0x1AFFFFFF)), // white/10
        ),
        focusedBorder: OutlineInputBorder(
           borderRadius: BorderRadius.circular(16),
           borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        hintStyle: TextStyle(color: textMainDark.withValues(alpha: 0.4)),
      ),
    );
  }
}
