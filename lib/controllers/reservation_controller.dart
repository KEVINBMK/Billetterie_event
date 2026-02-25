import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/reservation_model.dart';
import '../models/event_model.dart';

class ReservationController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Reservation> _reservations = [];
  bool _isLoading = false;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;

  void loadReservationsForEvent(String eventId) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getReservationsForEvent(eventId).listen((reservations) {
      _reservations = reservations;
      _isLoading = false;
      notifyListeners();
    });
  }

  void loadReservationsForOrganizer(String organizerId) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getReservationsForOrganizer(organizerId).listen((reservations) {
      _reservations = reservations;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> createReservation({
    required String eventId,
    required String organizerId,
    required String participantName,
    required String participantEmail,
    required int ticketsCount,
    required double totalPaid,
    required String qrCodeData,
  }) async {
    // Ici, vous pourriez vérifier la capacité restante avant de créer
    // Pour l'instant on crée directement
    final reservation = Reservation(
      id: '', // sera généré par Firestore
      eventId: eventId,
      organizerId: organizerId,
      participantName: participantName,
      participantEmail: participantEmail,
      ticketsCount: ticketsCount,
      totalPaid: totalPaid,
      reservationDate: DateTime.now(),
      qrCodeData: qrCodeData,
    );
    await _firestoreService.addReservation(reservation);
    // Après réservation, il faudrait décrémenter la capacité de l'événement
    // Mais cela nécessite de récupérer l'événement d'abord.
    return true;
  }
}