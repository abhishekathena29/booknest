import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool _loading = false;

  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _error;

  String? get error => _error;

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        debugPrint('Sign in successful');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    setLoading(true);
    setError(null);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(username);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'email': email,
              'username': username,
              'createdAt': Timestamp.now(),
              'onboarding_completed': false,
            });
        debugPrint('Sign up successful');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> signInWithGoogle() async {
    setLoading(true);
    setError(null);
    try {
      UserCredential credential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
        credential = await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(oauthCredential);
      }

      final user = credential.user;
      if (user == null) {
        return false;
      }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'email': user.email,
          'username':
              user.displayName ?? user.email?.split('@').first ?? 'Reader',
          'createdAt': Timestamp.now(),
          'onboarding_completed': false,
        });
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
