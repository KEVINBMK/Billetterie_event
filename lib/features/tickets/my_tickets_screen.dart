import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/ticket.dart';
import '../../core/services/firestore_service.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_app_bar.dart';
import '../../core/widgets/responsive_scaffold.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  String? _emailQuery;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final firestore = context.read<FirestoreService>();
    final email = _emailQuery ?? auth.user?.email;

    return ResponsiveScaffold(
      maxWidth: 700,
      appBar: LikitaAppBar(
        title: 'Mes billets',
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
            tooltip: 'Accueil',
          ),
        ],
      ),
      body: email == null || email.isEmpty
          ? _buildEmailForm()
          : FutureBuilder<List<Ticket>>(
              future: firestore.getTicketsByEmail(email),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tickets = snapshot.data!;
                if (tickets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 64, color: LikitaColors.primaryBlue.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        const Text('Aucun billet pour cet email.'),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _emailQuery = null),
                          child: const Text('Changer l\'email'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          ticket.event.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${ticket.quantity} place(s) · Acheté le ${ticket.purchasedAt.day}/${ticket.purchasedAt.month}/${ticket.purchasedAt.year}',
                        ),
                        trailing: const Icon(Icons.qr_code, color: LikitaColors.accentRed),
                        onTap: () => context.push('/ticket/${ticket.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmailForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Entrez l\'email utilisé lors de l\'achat pour voir vos billets.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final e = _emailController.text.trim();
              if (e.isNotEmpty) setState(() => _emailQuery = e);
            },
            child: const Text('Voir mes billets'),
          ),
        ],
      ),
    );
  }
}
