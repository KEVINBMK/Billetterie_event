import 'package:flutter/foundation.dart';

import 'event.dart';

@immutable
class Ticket {
  const Ticket({
    required this.id,
    required this.event,
    required this.holderName,
    required this.holderEmail,
    required this.quantity,
    required this.qrCodeData,
    required this.purchasedAt,
  });

  final String id;
  final Event event;
  final String holderName;
  final String holderEmail;
  final int quantity;
  final String qrCodeData;
  final DateTime purchasedAt;
}

