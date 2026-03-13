import 'package:booknest/firebase_options.dart';
import 'package:booknest/screens/auth/provider/auth_provider.dart';
import 'package:booknest/screens/main_navigation.dart';
import 'package:booknest/screens/onboarding/onboarding_screen.dart';
import 'package:booknest/screens/welcome/welcome_screen.dart';
import 'package:booknest/services/library_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:booknest/screens/community/provider/forum_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ForumProvider()),
        ChangeNotifierProvider(create: (context) => LibraryService()),
      ],
      child: const BookNestApp(),
    ),
  );
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
            ),
        textTheme: GoogleFonts.crimsonProTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF1A2730),
      ),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _SplashLoading();
        }
        final user = authSnapshot.data;
        if (user == null) {
          return const WelcomeScreen();
        }
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _SplashLoading();
            }
            if (userSnapshot.hasError) {
              return const MainNavigation();
            }
            final data = userSnapshot.data?.data();
            final completed = data?['onboarding_completed'] == true;
            return completed
                ? const MainNavigation()
                : const OnboardingScreen();
          },
        );
      },
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
