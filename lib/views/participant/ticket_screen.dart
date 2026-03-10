import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/reservation_model.dart';

class TicketScreen extends StatelessWidget {
  final Reservation reservation;
  const TicketScreen({Key? key, required this.reservation}) : super(key: key);

  Future<void> _printPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Billet pour ${reservation.eventTitle}',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: reservation.qrCodeData,
                  width: 200,
                  height: 200,
                ),
                pw.SizedBox(height: 20),
                pw.Text('Nom: ${reservation.participantName}'),
                pw.Text('Email: ${reservation.participantEmail}'),
                pw.Text('Quantité: ${reservation.ticketsCount}'),
                if (reservation.totalPaid > 0)
                  pw.Text('Payé: ${reservation.totalPaid} FC'),
              ],
            ),
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'billet.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Votre billet'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _printPdf,
          ),
        ],
      ),
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