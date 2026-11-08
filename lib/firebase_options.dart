import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZ0Vi-Klso456WmLP9sju7X3M7LGiyCwY',
    appId: '1:385933380753:android:335566bd4cc92edc574330',
    messagingSenderId: '385933380753',
    projectId: 'doctor-appointment-app-5cb47',
    storageBucket: 'doctor-appointment-app-5cb47.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZ0Vi-Klso456WmLP9sju7X3M7LGiyCwY',
    appId: '1:385933380753:android:335566bd4cc92edc574330',
    messagingSenderId: '385933380753',
    projectId: 'doctor-appointment-app-5cb47',
    storageBucket: 'doctor-appointment-app-5cb47.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDZ0Vi-Klso456WmLP9sju7X3M7LGiyCwY',
    appId: '1:385933380753:web:dummy',
    messagingSenderId: '385933380753',
    projectId: 'doctor-appointment-app-5cb47',
    storageBucket: 'doctor-appointment-app-5cb47.firebasestorage.app',
  );
}
