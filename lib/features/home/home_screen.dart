import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/state/auth_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/likita_nav_bar.dart';

/// Page d'accueil inspirée de Weezevent : hero, valeur ajoutée, CTA participants.
/// https://weezevent.com/fr/
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width > 600;

    if (auth.loading) {
      return Scaffold(
        appBar: LikitaNavBar(showNavLinks: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: textTheme.bodyMedium?.copyWith(color: LikitaColors.textDark),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: LikitaNavBar(currentTitle: 'Accueil'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero type Weezevent
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LikitaColors.primaryBlue,
                    LikitaColors.primaryBlue.withValues(alpha: 0.9),
                    LikitaColors.accentRed.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 56 : 24,
                    vertical: isWide ? 64 : 48,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'La solution de billetterie idéale pour vos événements',
                        style: textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isWide ? 34 : 26,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Proposez la meilleure expérience à vos participants avec une billetterie en ligne simple : créez votre événement, vendez vos billets et gérez tout en temps réel.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.5,
                          fontSize: isWide ? 17 : 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.go('/events'),
                            icon: const Icon(Icons.explore, size: 20),
                            label: const Text('Commencer maintenant'),
                            style: FilledButton.styleFrom(
                              backgroundColor: LikitaColors.accentRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (!auth.isLoggedIn)
                            OutlinedButton.icon(
                              onPressed: () => context.go('/register'),
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              label: const Text('Créer un événement'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            )
                          else if (auth.isOrganizer || auth.isAdmin)
                            OutlinedButton.icon(
                              onPressed: () => context.go('/dashboard'),
                              icon: const Icon(Icons.dashboard, size: 20),
                              label: const Text('Tableau de bord'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(width: 6),
                          Text(
                            'Inscription gratuite',
                            style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                          const SizedBox(width: 20),
                          Icon(Icons.check_circle, size: 18, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(width: 6),
                          Text(
                            'Sans engagement',
                            style: textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Section valeur ajoutée (type Weezevent "Flexible, Accessible, Fiable")
            _SectionTitle(
              title: 'Une billetterie adaptée à tous les événements',
              subtitle: 'Pour 10 ou 10 000 participants, lancez votre billetterie en quelques clics.',
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FeatureCard(
                              icon: Icons.event_available,
                              title: 'Créez votre événement gratuitement',
                              text: 'Configurez dates, lieu, tarifs et capacité. Personnalisez à votre image.',
                            ),
                            const SizedBox(width: 20),
                            _FeatureCard(
                              icon: Icons.sell,
                              title: 'Vendez et partagez en un instant',
                              text: 'Billetterie en ligne accessible à tous. Achat sans compte pour les participants.',
                            ),
                            const SizedBox(width: 20),
                            _FeatureCard(
                              icon: Icons.insights,
                              title: 'Suivez vos ventes en temps réel',
                              text: 'Tableau de bord organisateur : billets vendus, revenus et liste des réservations.',
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _FeatureCard(
                              icon: Icons.event_available,
                              title: 'Créez votre événement gratuitement',
                              text: 'Configurez dates, lieu, tarifs et capacité. Personnalisez à votre image.',
                              expanded: false,
                            ),
                            const SizedBox(height: 16),
                            _FeatureCard(
                              icon: Icons.sell,
                              title: 'Vendez et partagez en un instant',
                              text: 'Billetterie en ligne accessible à tous. Achat sans compte pour les participants.',
                              expanded: false,
                            ),
                            const SizedBox(height: 16),
                            _FeatureCard(
                              icon: Icons.insights,
                              title: 'Suivez vos ventes en temps réel',
                              text: 'Tableau de bord organisateur : billets vendus, revenus et liste des réservations.',
                              expanded: false,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // CTA participants
            Container(
              width: double.infinity,
              color: LikitaColors.primaryBlue.withValues(alpha: 0.08),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    child: Column(
                      children: [
                        Text(
                          'Un événement commence par sa billetterie.',
                          style: textTheme.headlineSmall?.copyWith(
                            color: LikitaColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Découvrez les prochains événements et réservez vos billets en quelques clics.',
                          style: textTheme.bodyLarge?.copyWith(color: LikitaColors.textDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/events'),
                          icon: const Icon(Icons.event),
                          label: const Text('Voir les événements'),
                          style: FilledButton.styleFrom(
                            backgroundColor: LikitaColors.accentRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer minimal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (kIsWeb)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextButton.icon(
                          onPressed: () async {
                            final urlStr = kApkDownloadUrl.isNotEmpty
                                ? kApkDownloadUrl
                                : '${Uri.base.origin}/apk/likita-event.apk';
                            final url = Uri.parse(urlStr);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Impossible d\'ouvrir le lien de téléchargement.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.android),
                          label: const Text('Télécharger l\'app Android'),
                          style: TextButton.styleFrom(
                            foregroundColor: LikitaColors.primaryBlue,
                          ),
                        ),
                      ),
                    Text(
                      '© LikitaEvent · Billetterie événementielle',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
      child: Column(
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              color: LikitaColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodyLarge?.copyWith(color: LikitaColors.textDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
    this.expanded = true,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: LikitaColors.primaryBlue.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LikitaColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: LikitaColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: LikitaColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: LikitaColors.textDark.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    return expanded ? Expanded(child: card) : card;
  }
}
