import 'dart:convert';
import 'package:http/http.dart' as http;

class LabyrinthePaymentService {
  final String baseUrl;
  final String apiToken;

  LabyrinthePaymentService({required this.baseUrl, required this.apiToken});

  /// Initie un dépôt mobile (paiement)
  /// Retourne un map avec 'success', 'reference', 'orderNumber' ou une erreur.
  Future<Map<String, dynamic>> initiateDeposit({
    required String phone,
    required double amount,
    required String currency, // 'USD' ou 'CDF'
    required String country,   // 'CD'
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

      final data = jsonDecode(response.body);

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
          'message': data['message'] ?? 'Erreur inconnue',
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