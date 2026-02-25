import 'package:flutter/foundation.dart';

enum LikitaUserRole { participant, organizer, admin }

@immutable
class LikitaUser {
  const LikitaUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String email;
  final String displayName;
  final LikitaUserRole role;
}

