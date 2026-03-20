import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color powderBlue = Color(0xFFAFC7FF);
  static const Color butterLight = Color(0xFFF7ED9C);
  static const Color primary = Color(0xFF7EA8F8);
  static const Color primaryLight = powderBlue;
  static const Color accentButter = Color(0xFFF1E27C);
  static const Color accentMint = Color(0xFF8CC7B0);
  static const Color backgroundLight = Color(0xFFF2EFEB);
  static const Color surfaceLight = Color(0xFFFFFBF7);
  static const Color borderLight = Color(0xFFE1D9D0);

  static const Color primaryDark = Color(0xFFF1E27C);
  static const Color backgroundDark = Color(0xFF131D2D);
  static const Color surfaceDark = Color(0xFF1B2940);
  static const Color borderDark = Color(0xFF304661);

  static const Color textMainLight = Color(0xFF20263A);
  static const Color textMutedLight = Color(0xFF6E7485);
  static const Color textMainDark = Color(0xFFF7F3EE);
  static const Color textMutedDark = Color(0xFFA7B6CA);

  static const Color statusStart = primary;
  static const Color statusExec = accentButter;
  static const Color statusDone = accentMint;

  static TextStyle get display =>
      GoogleFonts.nunito(fontWeight: FontWeight.w800);
  static TextStyle get body => GoogleFonts.nunito();
  static TextStyle get bodyKr => GoogleFonts.notoSansKr();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accentButter,
        tertiary: accentMint,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSurface: textMainLight,
        outline: borderLight,
        surfaceContainerHighest: Color(0xFFF6F1EC),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
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
          fontWeight: FontWeight.w700,
        ),
      ),
      cardColor: surfaceLight,
      dividerColor: borderLight,
      shadowColor: const Color(0x1E20263A),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: textMainLight.withValues(alpha: 0.42)),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: borderLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: primary,
        tertiary: accentMint,
        surface: surfaceDark,
        onPrimary: backgroundDark,
        onSurface: textMainDark,
        outline: borderDark,
        surfaceContainerHighest: Color(0xFF22324D),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
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
          fontWeight: FontWeight.w700,
        ),
      ),
      cardColor: surfaceDark,
      dividerColor: borderDark,
      shadowColor: Colors.black54,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: textMainDark.withValues(alpha: 0.42)),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: borderDark),
      ),
    );
  }
}
