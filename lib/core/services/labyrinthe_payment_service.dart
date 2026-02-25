import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service de paiement Mobile Money via l'API Labyrinthe RDC.
/// Intégré depuis mel_backend (Melvin).
class LabyrinthePaymentService {
  LabyrinthePaymentService({
    required this.baseUrl,
    required this.apiToken,
  });

  final String baseUrl;
  final String apiToken;

  /// Initie un dépôt mobile (paiement).
  /// Retourne un map avec 'success', 'reference', 'orderNumber' ou une erreur.
  Future<Map<String, dynamic>> initiateDeposit({
    required String phone,
    required double amount,
    required String currency,
    required String country,
    required String callbackUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/V1/payment/mobile');
    final payload = {
      'token': apiToken,
      'phone': phone,
      'amount': amount,
      'currency': currency,
      'country': country,
      'callback': callbackUrl,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'orderNumber': data['orderNumber'],
          'reference': data['reference'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Erreur inconnue',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
}
