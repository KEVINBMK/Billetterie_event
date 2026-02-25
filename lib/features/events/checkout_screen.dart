import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/labyrinthe_payment_service.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_app_bar.dart';
import '../../core/widgets/responsive_scaffold.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.eventId});
  final String eventId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _quantityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    BuildContext context, {
    required dynamic event,
    required FirestoreService firestore,
    required LabyrinthePaymentService paymentService,
  }) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final qty = int.tryParse(_quantityController.text) ?? 1;
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remplissez tous les champs obligatoires'),
          backgroundColor: LikitaColors.accentRed,
        ),
      );
      return;
    }
    if (qty > event.remainingSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plus que ${event.remainingSeats} places disponibles.'),
          backgroundColor: LikitaColors.accentRed,
        ),
      );
      return;
    }

    final isPaid = event.priceCfa > 0;
    if (isPaid && (phone.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de téléphone requis pour le paiement Mobile Money'),
          backgroundColor: LikitaColors.accentRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? paymentReference;

      if (isPaid) {
        final totalAmount = (event.priceCfa * qty).toDouble();
        final result = await paymentService.initiateDeposit(
          phone: phone,
          amount: totalAmount,
          currency: 'USD',
          country: 'CD',
          callbackUrl: ApiConstants.paymentCallbackUrl,
        );

        if (result['success'] != true) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']?.toString() ?? 'Échec du paiement'),
                backgroundColor: LikitaColors.accentRed,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        paymentReference = result['reference']?.toString() ?? result['orderNumber']?.toString();
      }

      final ticket = await firestore.createTicket(
        eventId: widget.eventId,
        eventTitle: event.title,
        holderName: name,
        holderEmail: email,
        quantity: qty,
        paymentReference: paymentReference,
      );

      if (context.mounted) {
        context.go('/ticket/${ticket.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: LikitaColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();
    final paymentService = context.read<LabyrinthePaymentService>();
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveScaffold(
      maxWidth: 500,
      appBar: LikitaAppBar(title: 'Acheter un billet'),
      body: FutureBuilder(
        future: firestore.getEventById(widget.eventId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final event = snapshot.data;
          if (event == null) {
            return Center(
              child: Text(
                'Événement introuvable.',
                style: textTheme.bodyLarge?.copyWith(color: LikitaColors.accentRed),
              ),
            );
          }

          final isPaid = event.priceCfa > 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: textTheme.titleLarge?.copyWith(color: LikitaColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  isPaid
                      ? '${event.priceCfa} USD / place'
                      : 'Gratuit',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPaid ? LikitaColors.accentRed : LikitaColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                if (isPaid) ...[
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone (Mobile Money)',
                      hintText: 'Ex: 243812345678',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requis pour le paiement Mobile Money via Labyrinthe RDC.',
                    style: textTheme.bodySmall?.copyWith(color: LikitaColors.textDark),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de places',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _submit(
                              context,
                              event: event,
                              firestore: firestore,
                              paymentService: paymentService,
                            ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isPaid ? 'Payer et confirmer' : 'Confirmer l\'achat'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
