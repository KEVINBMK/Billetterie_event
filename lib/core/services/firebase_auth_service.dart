import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/likita_user.dart';

/// Service d'authentification Firebase (Email), aligné avec mel_backend.
/// Collections Firestore : `users` (profil + rôle).
class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<LikitaUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return _userFromMap(user.uid, doc.data()!);
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    required LikitaUserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) return;
    await cred.user!.updateDisplayName(displayName);
    await _firestore.collection(_usersCollection).doc(cred.user!.uid).set({
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  LikitaUser? userFromFirebaseUser(User user, Map<String, dynamic>? data) {
    if (data == null) return null;
    return _userFromMap(user.uid, data);
  }

  LikitaUser _userFromMap(String id, Map<String, dynamic> map) {
    final roleStr = map['role'] as String? ?? 'participant';
    LikitaUserRole role = LikitaUserRole.participant;
    if (roleStr == 'organizer') role = LikitaUserRole.organizer;
    if (roleStr == 'admin') role = LikitaUserRole.admin;
    return LikitaUser(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: role,
    );
  }
}
