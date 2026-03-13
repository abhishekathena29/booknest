import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _seed = Color(0xFFC46A2D);
  static const Color _teal = Color(0xFF1F6F78);
  static const Color _ink = Color(0xFF1C2430);
  static const Color _paper = Color(0xFFF8F2E8);
  static const Color _paperDark = Color(0xFF14202A);

  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: _seed,
          secondary: _teal,
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF1E2CF),
        );

    final textTheme = GoogleFonts.crimsonProTextTheme().copyWith(
      headlineLarge: GoogleFonts.dmSerifDisplay(fontSize: 34, color: _ink),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 28, color: _ink),
      headlineSmall: GoogleFonts.dmSerifDisplay(fontSize: 24, color: _ink),
      titleLarge: GoogleFonts.crimsonPro(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _ink,
      ),
      bodyLarge: GoogleFonts.crimsonPro(fontSize: 17, color: _ink),
      bodyMedium: GoogleFonts.crimsonPro(
        fontSize: 15,
        color: _ink.withValues(alpha: 0.84),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _paper,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _ink,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.96),
        indicatorColor: _seed.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.crimsonPro(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? _seed : _ink.withValues(alpha: 0.65),
          );
        }),
      ),
    );
  }

  static ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _teal,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF58A7A5),
          secondary: const Color(0xFFF4B16B),
          surface: const Color(0xFF1B2833),
          surfaceContainerHighest: const Color(0xFF243443),
        );

    final base = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.crimsonProTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.dmSerifDisplay(
        fontSize: 34,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        color: Colors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _paperDark,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1B2833),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF21303D),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A2730).withValues(alpha: 0.96),
        indicatorColor: const Color(0xFF58A7A5).withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.crimsonPro(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
    );
  }
}
