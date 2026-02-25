import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_app_bar.dart';
import '../../core/widgets/responsive_scaffold.dart';

class TicketQrScreen extends StatelessWidget {
  const TicketQrScreen({super.key, required this.ticketId});
  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveScaffold(
      maxWidth: 500,
      appBar: LikitaAppBar(title: 'Mon billet'),
      body: FutureBuilder(
        future: firestore.getTicketById(ticketId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ticket = snapshot.data;
          if (ticket == null) {
            return Center(
              child: Text(
                'Billet introuvable.',
                style: textTheme.bodyLarge?.copyWith(color: LikitaColors.accentRed),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  ticket.event.title,
                  style: textTheme.headlineSmall?.copyWith(color: LikitaColors.primaryBlue),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${ticket.quantity} place(s) · ${ticket.holderName}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LikitaColors.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: ticket.qrCodeData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ticket.qrCodeData,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
