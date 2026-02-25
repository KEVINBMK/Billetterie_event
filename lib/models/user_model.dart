import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String role; // 'organizer' ou 'admin'
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.role,
    required this.createdAt,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'organizer',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
    };
  }
}