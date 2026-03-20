import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _ink = Color(0xFF20263A);
  static const _brand = Color(0xFF7EA8F8);
  static const _accent = Color(0xFFF2E77C);
  static const _surface = Color(0xFFF2EFEB);
  static const _surfaceDark = Color(0xFF0D1726);
  static const _card = Color(0xFFFFFBF7);
  static const _cardDark = Color(0xFF13263A);

  static ThemeData light() {
    return _buildTheme(
      brightness: Brightness.light,
      scaffold: _surface,
      card: _card,
      text: _ink,
      muted: const Color(0xFF6E7485),
      border: const Color(0xFFE1D9D0),
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      brightness: Brightness.dark,
      scaffold: _surfaceDark,
      card: _cardDark,
      text: const Color(0xFFF5F7FA),
      muted: const Color(0xFF9FB0C4),
      border: const Color(0xFF284158),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color card,
    required Color text,
    required Color muted,
    required Color border,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: _brand,
      onPrimary: Colors.white,
      secondary: _accent,
      onSecondary: _ink,
      error: const Color(0xFFB42318),
      onError: Colors.white,
      surface: card,
      onSurface: text,
      outline: border,
      shadow: Colors.black12,
      tertiary: const Color(0xFF2A9D8F),
      onTertiary: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ).apply(bodyColor: text, displayColor: text),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 1,
        shadowColor: _brand.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _brand,
          foregroundColor: _ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: _brand, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _brand.withValues(alpha: 0.14),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: card,
        indicatorColor: _brand.withValues(alpha: 0.14),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: border),
        selectedColor: _brand.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppThemeColors(
          brand: _brand,
          accent: _accent,
          muted: muted,
          border: border,
          card: card,
          surface: scaffold,
        ),
      ],
    );
  }
}

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.brand,
    required this.accent,
    required this.muted,
    required this.border,
    required this.card,
    required this.surface,
  });

  final Color brand;
  final Color accent;
  final Color muted;
  final Color border;
  final Color card;
  final Color surface;

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? brand,
    Color? accent,
    Color? muted,
    Color? border,
    Color? card,
    Color? surface,
  }) {
    return AppThemeColors(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      card: card ?? this.card,
      surface: surface ?? this.surface,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      border: Color.lerp(border, other.border, t) ?? border,
      card: Color.lerp(card, other.card, t) ?? card,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
    );
  }
}
