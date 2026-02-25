import 'dart:convert';
import 'package:http/http.dart' as http;

class LabyrinthePaymentService {
  final String baseUrl; // À définir, ex: 'https://api.labyrinthe-rdc.com/v1'
  final String apiKey;

  LabyrinthePaymentService({required this.baseUrl, required this.apiKey});

  /// Initie un paiement Mobile Money
  /// Retourne l'ID de transaction ou null en cas d'échec
  Future<String?> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/payment/initiate'); // À vérifier
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'amount': amount,
          'phone': phoneNumber,
          'description': description,
          // Ajoute d'autres champs requis par l'API
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // À adapter selon la structure de réponse
        return data['transactionId'];
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors du paiement: $e');
      return null;
    }
  }

  /// Vérifie le statut d'une transaction
  Future<Map<String, dynamic>?> checkPaymentStatus(String transactionId) async {
    final url = Uri.parse('$baseUrl/payment/status/$transactionId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Erreur vérification statut: $e');
    }
    return null;
  }
}