import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  AuthController() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserRole(String uid) async {
    _role = await _authService.getUserRole(uid);
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authService.signInWithEmail(email, password);
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    await _authService.signUpWithEmail(email, password, displayName);
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}