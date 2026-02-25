import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/models/ticket.dart';
import '../../core/services/firestore_service.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/widgets/likita_nav_bar.dart';

/// Écran de scan des billets pour les organisateurs. Fonctionne sur web (caméra du navigateur) et mobile.
class ScanTicketScreen extends StatefulWidget {
  const ScanTicketScreen({super.key});

  @override
  State<ScanTicketScreen> createState() => _ScanTicketScreenState();
}

class _ScanTicketScreenState extends State<ScanTicketScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final TextEditingController _manualCodeController = TextEditingController();
  bool _isProcessing = false;
  Timer? _cooldownTimer;
  static const _cooldownDuration = Duration(seconds: 2);

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _manualCodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _lookupAndShowTicket(String code) async {
    if (code.isEmpty || _isProcessing) return;
    setState(() => _isProcessing = true);
    _cooldownTimer?.cancel();

    final firestore = context.read<FirestoreService>();
    Ticket? ticket = await firestore.getTicketByQrCodeData(code);
    if (ticket == null) {
      ticket = await firestore.getTicketById(code);
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (ticket == null) {
      _showResultDialog(
        valid: false,
        message: 'Billet introuvable ou code invalide.',
      );
    } else {
      _showResultDialog(
        valid: true,
        ticket: ticket,
      );
      _manualCodeController.clear();
    }

    _cooldownTimer = Timer(_cooldownDuration, () {});
  }

  void _showResultDialog({required bool valid, Ticket? ticket, String? message}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              valid ? Icons.check_circle : Icons.error,
              color: valid ? LikitaColors.primaryBlue : LikitaColors.accentRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(valid ? 'Billet valide' : 'Billet invalide'),
          ],
        ),
        content: valid && ticket != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.event.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: LikitaColors.primaryBlue,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('${ticket.holderName} · ${ticket.holderEmail}'),
                  Text('${ticket.quantity} place(s)'),
                ],
              )
            : Text(message ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: LikitaNavBar(
        showNavLinks: false,
        currentTitle: 'Scanner un billet',
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    if (_isProcessing) return;
                    final barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;
                    final code = barcodes.first.rawValue?.trim();
                    if (code == null || code.isEmpty) return;
                    _lookupAndShowTicket(code);
                  },
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (isWeb)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Autorisez l\'accès à la caméra dans le navigateur pour scanner.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: LikitaColors.textDark,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(
                  'Ou entrez le code du billet manuellement',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LikitaColors.textDark,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualCodeController,
                        decoration: const InputDecoration(
                          hintText: 'Code QR ou ID du billet',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: _lookupAndShowTicket,
                        enabled: !_isProcessing,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.check),
                      onPressed: _isProcessing
                          ? null
                          : () => _lookupAndShowTicket(_manualCodeController.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
