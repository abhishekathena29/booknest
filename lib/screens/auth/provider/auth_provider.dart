import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void setError(String value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    try {
      final userCredential =  await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        print('Sign in successful');
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    try {
     final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        print('Sign up successful');
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  } 

  Future<void> signOut() async {
    await _auth.signOut();
  }
}