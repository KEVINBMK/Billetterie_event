import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/event_model.dart';

class EventController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _events = [];
  bool _isLoading = false;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;

  // Charger tous les événements
  void loadEvents() {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getEvents().listen((events) {
      _events = events;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Charger les événements d'un organisateur
  void loadEventsByOrganizer(String organizerId) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getEventsByOrganizer(organizerId).listen((events) {
      _events = events;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addEvent(Event event) async {
    await _firestoreService.addEvent(event);
  }

  Future<void> updateEvent(Event event) async {
    await _firestoreService.updateEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestoreService.deleteEvent(eventId);
  }
}