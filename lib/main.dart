import 'package:booknest/firebase_options.dart';
import 'package:booknest/screens/auth/provider/auth_provider.dart';
import 'package:booknest/screens/main_navigation.dart';
import 'package:booknest/screens/onboarding/onboarding_screen.dart';
import 'package:booknest/screens/welcome/welcome_screen.dart';
import 'package:booknest/services/library_service.dart';
import 'package:booknest/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.light(),
      themeMode: ThemeMode.light,
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
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon.png',
              height: 96,
              width: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'BookNest',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2730),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFD2691E)),
            ),
          ],
        ),
      ),
    );
  }
}
