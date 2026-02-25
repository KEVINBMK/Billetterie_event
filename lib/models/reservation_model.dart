// lib/models/reservation_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String eventId;
  final String? organizerId;
  final String eventTitle;          // Pour l'affichage sans re-query
  final String participantName;
  final String participantEmail;
  final int ticketsCount;
  final double totalPaid;
  final DateTime reservationDate;
  final String qrCodeData;
  final String? paymentReference;   // Référence retournée par Labyrinthe

  Reservation({
    required this.id,
    required this.eventId,
    this.organizerId,
    required this.eventTitle,
    required this.participantName,
    required this.participantEmail,
    required this.ticketsCount,
    required this.totalPaid,
    required this.reservationDate,
    required this.qrCodeData,
    this.paymentReference,
  });

  factory Reservation.fromFirestore(Map<String, dynamic> data, String id) {
    return Reservation(
      id: id,
      eventId: data['eventId'] ?? '',
      organizerId: data['organizerId'],
      eventTitle: data['eventTitle'] ?? '',
      participantName: data['participantName'] ?? '',
      participantEmail: data['participantEmail'] ?? '',
      ticketsCount: data['ticketsCount'] ?? 1,
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      qrCodeData: data['qrCodeData'] ?? '',
      paymentReference: data['paymentReference'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'organizerId': organizerId,
      'eventTitle': eventTitle,
      'participantName': participantName,
      'participantEmail': participantEmail,
      'ticketsCount': ticketsCount,
      'totalPaid': totalPaid,
      'reservationDate': reservationDate,
      'qrCodeData': qrCodeData,
      'paymentReference': paymentReference,
    };
  }
}