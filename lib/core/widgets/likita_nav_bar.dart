import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/likita_theme.dart';
import '../state/auth_state.dart';

/// Barre de navigation type site billetterie : logo, liens (Accueil, Événements, …), Connexion / S'inscrire à droite.
class LikitaNavBar extends StatelessWidget implements PreferredSizeWidget {
  const LikitaNavBar({
    super.key,
    this.showNavLinks = true,
    this.currentTitle,
  });

  final bool showNavLinks;
  final String? currentTitle;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 700;

    return AppBar(
      backgroundColor: LikitaColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        children: [
          _NavLogo(onTap: () => context.go('/')),
          if (showNavLinks && isWide) ...[
            const SizedBox(width: 32),
            _NavLink(label: 'Accueil', path: '/', currentTitle: currentTitle),
            const SizedBox(width: 8),
            _NavLink(label: 'Événements', path: '/events', currentTitle: currentTitle),
            if (auth.isLoggedIn) ...[
              const SizedBox(width: 8),
              _NavLink(label: 'Mes billets', path: '/my-tickets', currentTitle: currentTitle),
            ],
            if (auth.isOrganizer || auth.isAdmin) ...[
              const SizedBox(width: 8),
              _NavLink(label: 'Dashboard', path: '/dashboard', currentTitle: currentTitle),
              const SizedBox(width: 8),
              _NavLink(label: 'Scanner', path: '/dashboard/scan', currentTitle: currentTitle),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => context.go('/dashboard/event/new'),
                style: FilledButton.styleFrom(
                  backgroundColor: LikitaColors.accentRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Créer un événement'),
              ),
            ],
          ],
        ],
      ),
      actions: [
        if (auth.loading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
        else if (auth.isLoggedIn) ...[
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  auth.user?.displayName ?? auth.user?.email ?? 'Compte',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          TextButton.icon(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            label: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ] else ...[
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Se connecter', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => context.go('/register'),
            style: FilledButton.styleFrom(
              backgroundColor: LikitaColors.accentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Créer un événement'),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _NavLogo extends StatelessWidget {
  const _NavLogo({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Likita',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'Event',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: LikitaColors.accentRed,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.path,
    this.currentTitle,
  });

  final String label;
  final String path;
  final String? currentTitle;

  @override
  Widget build(BuildContext context) {
    final isCurrent = currentTitle != null && _titleMatchesPath(currentTitle!, path);
    return TextButton(
      onPressed: () => context.go(path),
      child: Text(
        label,
        style: TextStyle(
          color: isCurrent ? Colors.white : Colors.white70,
          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  bool _titleMatchesPath(String title, String path) {
    if (path == '/') return title == 'Accueil' || title.isEmpty;
    if (path == '/events') return title.toLowerCase().contains('événement');
    if (path == '/my-tickets') return title.toLowerCase().contains('billet');
    if (path == '/dashboard') return title.toLowerCase().contains('dashboard');
    if (path == '/dashboard/scan') return title.toLowerCase().contains('scanner');
    return false;
  }
}
