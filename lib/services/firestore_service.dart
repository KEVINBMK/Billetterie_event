import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/reservation_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---- Événements ----
  Stream<List<Event>> getEvents() {
    return _firestore.collection('evenements').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<Event>> getEventsByOrganizer(String organizerId) {
    return _firestore
        .collection('evenements')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<void> addEvent(Event event) async {
    await _firestore.collection('evenements').add(event.toFirestore());
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('evenements').doc(event.id).update(event.toFirestore());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('evenements').doc(eventId).delete();
  }

  // ---- Réservations ----
  Future<void> addReservation(Reservation reservation) async {
    await _firestore.collection('reservations').add(reservation.toFirestore());
  }

  Stream<List<Reservation>> getReservationsForEvent(String eventId) {
    return _firestore
        .collection('reservations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reservation.fromFirestore(doc.data(), doc.id)).toList());
  }

  Stream<List<Reservation>> getReservationsForOrganizer(String organizerId) {
    return _firestore
        .collection('reservations')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Reservation.fromFirestore(doc.data(), doc.id)).toList());
  }

  // Mettre à jour le nombre de places disponibles d'un événement
  Future<void> updateEventCapacity(String eventId, int newCapacity) async {
    await _firestore.collection('evenements').doc(eventId).update({'capacity': newCapacity});
  }
}