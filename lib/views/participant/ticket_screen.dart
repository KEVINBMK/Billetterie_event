import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/reservation_model.dart';

class TicketScreen extends StatelessWidget {
  final Reservation reservation;
  const TicketScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Votre billet')),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Billet confirmé !',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                QrImageView(
                  data: reservation.qrCodeData,
                  version: QrVersions.auto,
                  size: 200,
                ),
                SizedBox(height: 20),
                Text('Nom : ${reservation.participantName}'),
                Text('Email : ${reservation.participantEmail}'),
                Text('Événement : ${reservation.eventTitle}'),
                Text('Quantité : ${reservation.ticketsCount}'),
                if (reservation.totalPaid > 0)
                  Text('Payé : ${reservation.totalPaid} FC'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}