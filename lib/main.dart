import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'core/theme/likita_theme.dart';
import 'core/constants/api_constants.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/labyrinthe_payment_service.dart';
import 'core/state/auth_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LikitaEventApp());
}

class LikitaEventApp extends StatelessWidget {
  const LikitaEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final paymentService = LabyrinthePaymentService(
      baseUrl: ApiConstants.labyrintheBaseUrl,
      apiToken: ApiConstants.labyrintheApiToken,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState(authService),
        ),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<LabyrinthePaymentService>.value(value: paymentService),
      ],
      child: MaterialApp.router(
        title: 'LikitaEvent',
        debugShowCheckedModeBanner: false,
        theme: buildLikitaTheme(),
        routerConfig: createRouter(),
      ),
    );
  }
}
