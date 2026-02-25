import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/likita_theme.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/state/auth_state.dart';
import 'features/auth/login_register_screens.dart';
import 'features/events/events_screens.dart';
import 'features/events/event_detail_screen.dart';
import 'features/events/checkout_screen.dart';
import 'features/tickets/my_tickets_screen.dart';
import 'features/tickets/ticket_qr_screen.dart';
import 'features/dashboard/organizer_dashboard_screen.dart';
import 'features/dashboard/organizer_event_form_screen.dart';
import 'features/dashboard/scan_ticket_screen.dart';
import 'features/home/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = context.read<AuthState>();
      final path = state.matchedLocation;
      if (!path.startsWith('/dashboard')) return null;
      if (auth.loading) return null;
      if (!auth.isLoggedIn) return '/login';
      if (!auth.isOrganizer && !auth.isAdmin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsListScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/checkout',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CheckoutScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/my-tickets',
        builder: (context, state) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: '/ticket/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketQrScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const OrganizerDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/scan',
        builder: (context, state) => const ScanTicketScreen(),
      ),
      GoRoute(
        path: '/dashboard/event/new',
        builder: (context, state) => const OrganizerEventFormScreen(),
      ),
      GoRoute(
        path: '/dashboard/event/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrganizerEventFormScreen(eventId: id);
        },
      ),
    ],
  );
}
