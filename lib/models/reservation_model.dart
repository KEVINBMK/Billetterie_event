import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String eventId;
  final String? organizerId; // pour faciliter les requêtes
  final String participantName;
  final String participantEmail;
  final int ticketsCount;
  final double totalPaid; // 0 si gratuit
  final DateTime reservationDate;
  final String qrCodeData; // pour générer le QR plus tard

  Reservation({
    required this.id,
    required this.eventId,
    this.organizerId,
    required this.participantName,
    required this.participantEmail,
    required this.ticketsCount,
    required this.totalPaid,
    required this.reservationDate,
    required this.qrCodeData,
  });

  factory Reservation.fromFirestore(Map<String, dynamic> data, String id) {
    return Reservation(
      id: id,
      eventId: data['eventId'] ?? '',
      organizerId: data['organizerId'],
      participantName: data['participantName'] ?? '',
      participantEmail: data['participantEmail'] ?? '',
      ticketsCount: data['ticketsCount'] ?? 1,
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      qrCodeData: data['qrCodeData'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'organizerId': organizerId,
      'participantName': participantName,
      'participantEmail': participantEmail,
      'ticketsCount': ticketsCount,
      'totalPaid': totalPaid,
      'reservationDate': reservationDate,
      'qrCodeData': qrCodeData,
    };
  }
}