import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final int capacity;
  final double price; // 0.0 pour gratuit
  final String organizerId; // UID de l'organisateur
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    required this.capacity,
    required this.price,
    required this.organizerId,
    required this.createdAt,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      capacity: data['capacity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      organizerId: data['organizerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'price': price,
      'organizerId': organizerId,
      'createdAt': createdAt,
    };
  }
}