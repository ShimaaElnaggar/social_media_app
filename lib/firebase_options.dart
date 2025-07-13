import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        throw UnsupportedError('This platform is not supported.');
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['WEB_API_KEY'] ?? '',
    appId: '1:733426712607:web:ffd576ffb2f0a1c41a152a',
    messagingSenderId: '733426712607',
    projectId: 'social-media-app-58679',
    authDomain: 'social-media-app-58679.firebaseapp.com',
    storageBucket: 'social-media-app-58679.firebasestorage.app',
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: dotenv.env['ANDROID_API_KEY'] ?? '',
    appId: '1:733426712607:android:685f8084c35baa931a152a',
    messagingSenderId: '733426712607',
    projectId: 'social-media-app-58679',
    storageBucket: 'social-media-app-58679.firebasestorage.app',
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['IOS_API_KEY'] ?? '',
    appId: '1:733426712607:ios:f3b1a196b2c2a8c51a152a',
    messagingSenderId: '733426712607',
    projectId: 'social-media-app-58679',
    storageBucket: 'social-media-app-58679.firebasestorage.app',
    iosBundleId: 'com.example.socialMediaApp',
  );
}
