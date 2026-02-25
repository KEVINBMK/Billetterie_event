import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/firestore_service.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_nav_bar.dart';

class OrganizerDashboardScreen extends StatelessWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final firestore = context.read<FirestoreService>();
    final organizerId = auth.user?.id ?? '';

    if (!auth.isOrganizer && !auth.isAdmin) {
      return Scaffold(
        appBar: LikitaNavBar(showNavLinks: true, currentTitle: 'Dashboard'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 64, color: LikitaColors.accentRed.withValues(alpha: 0.8)),
                const SizedBox(height: 16),
                Text(
                  'Accès réservé aux organisateurs et administrateurs.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: LikitaColors.accentRed),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre compte n\'a pas les droits pour accéder au tableau de bord.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LikitaColors.textDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: LikitaNavBar(
        showNavLinks: true,
        currentTitle: 'Dashboard',
      ),
      body: FutureBuilder<List<Event>>(
        future: firestore.getEventsForDashboard(organizerId, auth.isAdmin),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          var totalSold = 0;
          var totalRevenue = 0;
          for (final e in events) {
            totalSold += e.ticketsSold;
            totalRevenue += e.ticketsSold * e.priceCfa;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatCard(
                      label: 'Événements',
                      value: '${events.length}',
                      icon: Icons.event,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Billets vendus',
                      value: '$totalSold',
                      icon: Icons.confirmation_num_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Revenus (USD)',
                      value: '$totalRevenue',
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scanner les billets'),
                      onPressed: () => context.push('/dashboard/scan'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (auth.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Vue admin : tous les événements',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LikitaColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  'Mes événements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucun événement créé.'),
                    ),
                  )
                else
                  ...events.map((e) => Card(
                        child: ListTile(
                          title: Text(e.title),
                          subtitle: Text(
                            auth.isAdmin && e.organizerName.isNotEmpty
                                ? 'Par ${e.organizerName} · ${e.ticketsSold}/${e.capacity} billets · ${e.dateTime.day}/${e.dateTime.month}/${e.dateTime.year}'
                                : '${e.ticketsSold}/${e.capacity} billets · ${e.dateTime.day}/${e.dateTime.month}/${e.dateTime.year}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    context.push('/dashboard/event/${e.id}'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Supprimer ?'),
                                      content: Text(
                                        'Supprimer "${e.title}" ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await firestore.deleteEvent(e.id);
                                    if (context.mounted) {
                                      context.go('/dashboard');
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
