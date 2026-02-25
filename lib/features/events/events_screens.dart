import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_nav_bar.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  Future<List<Event>>? _eventsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_eventsFuture == null) {
      _eventsFuture = context.read<FirestoreService>().getUpcomingEventsSafe();
    }
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = context.read<FirestoreService>().getUpcomingEventsSafe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      appBar: LikitaNavBar(currentTitle: 'Événements', showNavLinks: true),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture ?? Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: LikitaColors.accentRed.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger les événements.',
                      style: textTheme.bodyLarge?.copyWith(color: LikitaColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _loadEvents,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: LikitaColors.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: LikitaColors.primaryBlue.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun événement à venir.',
                    style: textTheme.bodyLarge?.copyWith(color: LikitaColors.textDark),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isWide
                  ? _EventsGrid(events: events)
                  : _EventsList(events: events),
            ),
          );
        },
      ),
    );
  }
}

class _EventsGrid extends StatelessWidget {
  const _EventsGrid({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        childAspectRatio: 0.75,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) => _EventCard(event: events[index]),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _EventCard(event: events[index], compact: true),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.compact = false});

  final Event event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image ou placeholder
            AspectRatio(
              aspectRatio: compact ? 2.2 : 16 / 9,
              child: event.imageUrl.isNotEmpty
                  ? Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: LikitaColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year}',
                          style: textTheme.labelMedium?.copyWith(
                            color: LikitaColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${event.priceCfa} USD',
                        style: textTheme.titleMedium?.copyWith(
                          color: LikitaColors.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LikitaColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: event.isSoldOut
                              ? LikitaColors.accentRed.withValues(alpha: 0.15)
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.isSoldOut ? 'Complet' : '${event.remainingSeats} places',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: event.isSoldOut ? LikitaColors.accentRed : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: LikitaColors.primaryBlue.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.event, size: 48, color: LikitaColors.primaryBlue.withValues(alpha: 0.4)),
      ),
    );
  }
}
