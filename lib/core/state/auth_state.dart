import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/likita_user.dart';
import '../services/firebase_auth_service.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  final FirebaseAuthService _authService;
  LikitaUser? _user;
  bool _loading = true;

  LikitaUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  bool get isOrganizer => _user?.role == LikitaUserRole.organizer;
  bool get isAdmin => _user?.role == LikitaUserRole.admin;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _loading = false;
      notifyListeners();
      return;
    }
    _user = await _authService.getCurrentUserProfile();
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailPassword(email, password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required LikitaUserRole role,
  }) async {
    await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
