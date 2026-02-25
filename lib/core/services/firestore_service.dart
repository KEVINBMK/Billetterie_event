import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/ticket.dart';

/// Service Firestore pour événements et billets.
///
/// Collection `evenements` (schéma Firestore) :
/// - capacity (number)
/// - createdAt (timestamp)
/// - date (timestamp)
/// - description (string)
/// - imageUrl (null ou string)
/// - location (string)
/// - organizerId (string)
/// - price (number)
/// - title (string)
///
/// Champs optionnels ajoutés par l'app à la création : organizerName, ticketsSold.
/// En lecture : organizerName et ticketsSold ont des valeurs par défaut si absents.
///
/// Autres collections : `users` (auth), `reservations` (mel_backend), `tickets` (legacy).
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _eventsCollection = 'evenements';
  static const String _ticketsCollection = 'tickets';
  static const String _reservationsCollection = 'reservations';

  Future<List<Event>> getUpcomingEvents() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final q = await _firestore
        .collection(_eventsCollection)
        .orderBy('date')
        .get();
    final events = q.docs.map(_eventFromDoc).where((e) => !e.dateTime.isBefore(startOfToday)).toList();
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return events;
  }

  /// Charge les événements à venir sans faire planter l'app en cas d'erreur Firestore (règles, index, etc.).
  /// En cas d'échec, tente un get() sans orderBy puis filtre/tri en mémoire, sinon retourne [].
  Future<List<Event>> getUpcomingEventsSafe() async {
    try {
      return await getUpcomingEvents();
    } catch (_) {
      try {
        final q = await _firestore.collection(_eventsCollection).get();
        final startOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final events = q.docs
            .map(_eventFromDoc)
            .where((e) => !e.dateTime.isBefore(startOfToday))
            .toList();
        events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return events;
      } catch (_) {
        return [];
      }
    }
  }

  Future<Event?> getEventById(String id) async {
    final doc = await _firestore.collection(_eventsCollection).doc(id).get();
    if (!doc.exists) return null;
    return _eventFromDoc(doc);
  }

  Stream<List<Event>> streamUpcomingEvents() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return _firestore
        .collection(_eventsCollection)
        .orderBy('date')
        .snapshots()
        .map((s) {
          final events = s.docs.map(_eventFromDoc).where((e) => !e.dateTime.isBefore(startOfToday)).toList();
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

  Future<List<Event>> getEventsByOrganizer(String organizerId) async {
    final all = await getAllEvents();
    return all.where((e) => e.organizerId == organizerId).toList();
  }

  /// Tous les événements (pour admin ou requêtes sans index composite).
  Future<List<Event>> getAllEvents() async {
    final q = await _firestore
        .collection(_eventsCollection)
        .orderBy('date', descending: true)
        .get();
    return q.docs.map(_eventFromDoc).toList();
  }

  /// Événements à afficher dans le dashboard : tous si admin, sinon ceux de l'organisateur.
  Future<List<Event>> getEventsForDashboard(String userId, bool isAdmin) async {
    if (isAdmin) return getAllEvents();
    return getEventsByOrganizer(userId);
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    required String imageUrl,
    required int capacity,
    required int priceCfa,
    required String organizerId,
    required String organizerName,
  }) async {
    await _firestore.collection(_eventsCollection).add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'imageUrl': imageUrl.isEmpty ? null : imageUrl,
      'capacity': capacity,
      'price': priceCfa,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'ticketsSold': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    final map = Map<String, dynamic>.from(data);
    if (map.containsKey('priceCfa')) {
      map['price'] = map.remove('priceCfa');
    }
    if (map.containsKey('date') && map['date'] is DateTime) {
      map['date'] = Timestamp.fromDate(map['date'] as DateTime);
    }
    await _firestore.collection(_eventsCollection).doc(id).update(map);
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.collection(_eventsCollection).doc(id).delete();
  }

  Future<Ticket> createTicket({
    required String eventId,
    required String eventTitle,
    required String holderName,
    required String holderEmail,
    required int quantity,
    String? paymentReference,
  }) async {
    final eventRef = _firestore.collection(_eventsCollection).doc(eventId);
    final eventDoc = await eventRef.get();
    if (!eventDoc.exists) throw Exception('Event not found');
    final eventData = eventDoc.data()!;
    final capacity = eventData['capacity'] as int;
    final ticketsSold = (eventData['ticketsSold'] as int?) ?? 0;
    if (ticketsSold + quantity > capacity) throw Exception('Plus assez de places');
    final price = (eventData['price'] as num?)?.toDouble() ?? (eventData['priceCfa'] as int?)?.toDouble() ?? 0.0;
    final totalPaid = price * quantity;
    final organizerId = eventData['organizerId'] as String?;
    final qrCodeData = 'LIKITA-${DateTime.now().millisecondsSinceEpoch}-$eventId';
    final now = DateTime.now();

    // Écriture dans reservations (schéma mel_backend) pour compatibilité avec le backend Melvin
    final ref = await _firestore.collection(_reservationsCollection).add({
      'eventId': eventId,
      'organizerId': organizerId,
      'eventTitle': eventTitle,
      'participantName': holderName,
      'participantEmail': holderEmail,
      'ticketsCount': quantity,
      'totalPaid': totalPaid,
      'reservationDate': Timestamp.fromDate(now),
      'qrCodeData': qrCodeData,
      'paymentReference': paymentReference,
    });
    await eventRef.update({'ticketsSold': FieldValue.increment(quantity)});
    final event = await getEventById(eventId);
    return Ticket(
      id: ref.id,
      event: event!,
      holderName: holderName,
      holderEmail: holderEmail,
      quantity: quantity,
      qrCodeData: qrCodeData,
      purchasedAt: now,
    );
  }

  Future<List<Ticket>> getTicketsByEmail(String email) async {
    final results = <Ticket>[];
    try {
      final resQuery = await _firestore
          .collection(_reservationsCollection)
          .where('participantEmail', isEqualTo: email)
          .get();
      for (final doc in resQuery.docs) {
        final t = await _reservationToTicket(doc);
        if (t != null) results.add(t);
      }
    } catch (_) {}
    try {
      final tickQuery = await _firestore
          .collection(_ticketsCollection)
          .where('holderEmail', isEqualTo: email)
          .get();
      for (final doc in tickQuery.docs) {
        final t = await _ticketFromDoc(doc);
        if (t != null) results.add(t);
      }
    } catch (_) {}
    results.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return results;
  }

  Future<Ticket?> getTicketById(String ticketId) async {
    var doc = await _firestore.collection(_reservationsCollection).doc(ticketId).get();
    if (doc.exists) return await _reservationToTicket(doc);
    doc = await _firestore.collection(_ticketsCollection).doc(ticketId).get();
    if (doc.exists) return await _ticketFromDoc(doc);
    return null;
  }

  /// Trouve un billet par le contenu du QR (qrCodeData). Utilisé par le scan organisateur.
  Future<Ticket?> getTicketByQrCodeData(String qrCodeData) async {
    if (qrCodeData.isEmpty) return null;
    try {
      final resQuery = await _firestore
          .collection(_reservationsCollection)
          .where('qrCodeData', isEqualTo: qrCodeData)
          .limit(1)
          .get();
      if (resQuery.docs.isNotEmpty) return await _reservationToTicket(resQuery.docs.first);
    } catch (_) {}
    try {
      final tickQuery = await _firestore
          .collection(_ticketsCollection)
          .where('qrCodeData', isEqualTo: qrCodeData)
          .limit(1)
          .get();
      if (tickQuery.docs.isNotEmpty) return await _ticketFromDoc(tickQuery.docs.first);
    } catch (_) {}
    return null;
  }

  Future<Ticket?> _reservationToTicket(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;
    final eventId = data['eventId'] as String?;
    final event = eventId != null ? await getEventById(eventId) : null;
    if (event == null) return null;
    final reservationDate = (data['reservationDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Ticket(
      id: doc.id,
      event: event,
      holderName: data['participantName'] as String? ?? '',
      holderEmail: data['participantEmail'] as String? ?? '',
      quantity: (data['ticketsCount'] as int?) ?? 1,
      qrCodeData: data['qrCodeData'] as String? ?? '',
      purchasedAt: reservationDate,
    );
  }

  Future<Ticket?> _ticketFromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;
    final eventId = data['eventId'] as String?;
    final event = eventId != null ? await getEventById(eventId) : null;
    if (event == null) return null;
    final purchasedAt = (data['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return Ticket(
      id: doc.id,
      event: event,
      holderName: data['holderName'] as String? ?? '',
      holderEmail: data['holderEmail'] as String? ?? '',
      quantity: (data['quantity'] as int?) ?? 1,
      qrCodeData: data['qrCodeData'] as String? ?? '',
      purchasedAt: purchasedAt,
    );
  }

  Event _eventFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final date = (d['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final imageUrl = d['imageUrl'];
    return Event(
      id: doc.id,
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      dateTime: date,
      location: d['location'] as String? ?? '',
      capacity: (d['capacity'] as int?) ?? 0,
      ticketsSold: (d['ticketsSold'] as int?) ?? 0,
      priceCfa: (d['price'] as int?) ?? (d['priceCfa'] as int?) ?? 0,
      imageUrl: imageUrl == null ? '' : imageUrl.toString(),
      organizerName: d['organizerName'] as String? ?? '',
      organizerId: d['organizerId'] as String? ?? '',
    );
  }
}
