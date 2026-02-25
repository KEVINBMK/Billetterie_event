// Fichier généré pour la configuration Firebase (projet billetterieevent-a023d).
// Pour régénérer avec FlutterFire CLI : dart run flutterfire_cli:flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'est pas supporté pour cette plateforme. '
          'Utilisez FlutterFire CLI : dart run flutterfire_cli:flutterfire configure',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB5bYjB3SJ_i64hqXNzNLEHFsTzMgtx_yc',
    appId: '1:30607756645:web:placeholder',
    messagingSenderId: '30607756645',
    projectId: 'billetterieevent-a023d',
    authDomain: 'billetterieevent-a023d.firebaseapp.com',
    storageBucket: 'billetterieevent-a023d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5bYjB3SJ_i64hqXNzNLEHFsTzMgtx_yc',
    appId: '1:30607756645:android:458a72b3bf9a914243658c',
    messagingSenderId: '30607756645',
    projectId: 'billetterieevent-a023d',
    storageBucket: 'billetterieevent-a023d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5bYjB3SJ_i64hqXNzNLEHFsTzMgtx_yc',
    appId: '1:30607756645:ios:PLACEHOLDER',
    messagingSenderId: '30607756645',
    projectId: 'billetterieevent-a023d',
    storageBucket: 'billetterieevent-a023d.firebasestorage.app',
  );
}
