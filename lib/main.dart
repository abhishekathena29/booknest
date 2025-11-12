import 'package:booknest/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding/welcome_screen.dart';

void main() {
  runApp(const BookNestApp());
}

class BookNestApp extends StatelessWidget {
  const BookNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFFD2691E),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFFD2691E),
              secondary: const Color(0xFF2D7A7B),
              surface: const Color(0xFFFFF8F0),
            ),
        textTheme: GoogleFonts.crimsonProTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D7A7B),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFF2D7A7B),
              secondary: const Color(0xFF5BA9AA),
              surface: const Color(0xFF1A2730),
              background: const Color(0xFF1A2730),
            ),
        textTheme: GoogleFonts.crimsonProTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF1A2730),
      ),
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
    );
  }
}
