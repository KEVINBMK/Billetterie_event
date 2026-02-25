/// Constantes pour l'API Labyrinthe RDC (paiement Mobile Money).
/// Aligné avec mel_backend (Melvin).
class ApiConstants {
  ApiConstants._();

  static const String labyrintheBaseUrl = 'https://api.labyrinthe-rdc.com';
  /// Token API Labyrinthe. Remplacer par le vrai token en production.
  static const String labyrintheApiToken = r'$2y$12$JA9F0RS1ADcVlN0v1SeCvOAoR4rwiYSrBy5sJvAkL1cq.uuclzt.u';
  /// URL de callback appelée par Labyrinthe après paiement (à configurer selon votre hébergement).
  static const String paymentCallbackUrl = 'https://ton-app.com/callback';
}
