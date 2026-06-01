import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('This platform is not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBv6G1RLyjzwaRlKoQC0arys7MkXUWCFuY',
    appId: '1:396369034947:android:b7e97308368e44cc2aec76',
    messagingSenderId: '396369034947',
    projectId: 'replyai-749f7',
    storageBucket: 'replyai-749f7.firebasestorage.app',
  );
}
