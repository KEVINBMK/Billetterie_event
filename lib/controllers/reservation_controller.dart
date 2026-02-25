// lib/controllers/reservation_controller.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/firestore_service.dart';
import '../services/labyrinthe_payment_service.dart';
import '../models/event_model.dart';
import '../models/reservation_model.dart';
import '../core/constants.dart'; // à créer

class ReservationController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LabyrinthePaymentService _paymentService = LabyrinthePaymentService(
    baseUrl: ApiConstants.labyrintheBaseUrl,
    apiToken: ApiConstants.labyrintheApiToken,
  );

  List<Reservation> _reservations = [];
  Reservation? _lastReservation;
  bool _isLoading = false;

  List<Reservation> get reservations => _reservations;
  Reservation? get lastReservation => _lastReservation;
  bool get isLoading => _isLoading;

  // Charger les réservations pour un événement
  void loadReservationsForEvent(String eventId) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getReservationsForEvent(eventId).listen((reservations) {
      _reservations = reservations;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Créer une réservation (avec paiement si nécessaire)
  Future<bool> createReservation({
    required Event event,
    required String participantName,
    required String participantEmail,
    String? participantPhone, // requis si payant
    required int ticketsCount,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Vérifier la capacité
      if (event.capacity < ticketsCount) {
        throw Exception('Plus assez de places disponibles');
      }

      final totalAmount = event.price * ticketsCount;
      final qrData = const Uuid().v4(); // identifiant unique pour le QR code

      String? paymentRef;

      // 2. Si l'événement est payant, initier le paiement
      if (event.price > 0) {
        if (participantPhone == null || participantPhone.isEmpty) {
          throw Exception('Numéro de téléphone requis pour le paiement');
        }

        final paymentResult = await _paymentService.initiateDeposit(
          phone: participantPhone,
          amount: totalAmount,
          currency: 'USD', // ou 'CDF' selon ton besoin
          country: 'CD',
          callbackUrl: ApiConstants.paymentCallbackUrl, // URL factice
        );

        if (paymentResult['success'] != true) {
          throw Exception(paymentResult['message'] ?? 'Échec du paiement');
        }

        paymentRef = paymentResult['reference'] ?? paymentResult['orderNumber'];
      }

      // 3. Créer la réservation dans Firestore
      final reservation = Reservation(
        id: '', // Firestore générera l'ID
        eventId: event.id,
        organizerId: event.organizerId,
        eventTitle: event.title,
        participantName: participantName,
        participantEmail: participantEmail,
        ticketsCount: ticketsCount,
        totalPaid: totalAmount,
        reservationDate: DateTime.now(),
        qrCodeData: qrData,
        paymentReference: paymentRef,
      );

      await _firestoreService.addReservation(reservation);

      // 4. Mettre à jour la capacité de l'événement
      await _firestoreService.updateEventCapacity(event.id, event.capacity - ticketsCount);

      // 5. Sauvegarder pour affichage
      _lastReservation = reservation;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur réservation: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}