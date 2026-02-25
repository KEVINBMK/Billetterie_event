import 'package:flutter/foundation.dart';

@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.capacity,
    required this.priceCfa,
    required this.imageUrl,
    required this.organizerName,
    required this.organizerId,
    required this.ticketsSold,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final int capacity;
  final int ticketsSold;
  final int priceCfa;
  final String imageUrl;
  final String organizerName;
  final String organizerId;

  int get remainingSeats => capacity - ticketsSold;

  bool get isSoldOut => remainingSeats <= 0;
}

