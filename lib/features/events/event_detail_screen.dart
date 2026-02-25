import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_nav_bar.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: LikitaNavBar(showNavLinks: true, currentTitle: 'Événement'),
      body: FutureBuilder<Event?>(
        future: firestore.getEventById(eventId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final event = snapshot.data;
          if (event == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: LikitaColors.accentRed.withValues(alpha: 0.8)),
                    const SizedBox(height: 16),
                    Text(
                      'Événement introuvable.',
                      style: textTheme.bodyLarge?.copyWith(color: LikitaColors.accentRed),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero image
                if (event.imageUrl.isNotEmpty)
                  AspectRatio(
                    aspectRatio: isWide ? 21 / 9 : 16 / 9,
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: isWide ? 21 / 9 : 16 / 9,
                    child: _placeholder(context),
                  ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: LikitaColors.primaryBlue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} · ${event.dateTime.hour.toString().padLeft(2, '0')}h${event.dateTime.minute.toString().padLeft(2, '0')}',
                                  style: textTheme.labelLarge?.copyWith(
                                    color: LikitaColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: event.isSoldOut
                                      ? LikitaColors.accentRed.withValues(alpha: 0.15)
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  event.isSoldOut ? 'Complet' : '${event.remainingSeats} places',
                                  style: TextStyle(
                                    color: event.isSoldOut ? LikitaColors.accentRed : Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            event.title,
                            style: textTheme.headlineMedium?.copyWith(
                              color: LikitaColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 20, color: LikitaColors.textDark.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: textTheme.bodyLarge?.copyWith(color: LikitaColors.textDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            event.description,
                            style: textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Chip(
                                label: Text('${event.priceCfa} USD / place'),
                                backgroundColor: LikitaColors.accentRed.withValues(alpha: 0.15),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: event.isSoldOut
                                  ? null
                                  : () => context.push('/events/$eventId/checkout'),
                              style: FilledButton.styleFrom(
                                backgroundColor: LikitaColors.accentRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              child: Text(event.isSoldOut ? 'Complet' : 'Acheter un billet'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: LikitaColors.primaryBlue.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.event, size: 64, color: LikitaColors.primaryBlue.withValues(alpha: 0.4)),
      ),
    );
  }
}
