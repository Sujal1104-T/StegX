import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpyekZIKjw718qbF-IwxtZKMwuZMBupOg',
    appId: '1:233214734477:web:414e9555e68dc163a132c4',
    messagingSenderId: '233214734477',
    projectId: 'stegx-607ce',
    authDomain: 'stegx-607ce.firebaseapp.com',
    storageBucket: 'stegx-607ce.firebasestorage.app',
    measurementId: 'G-KPE4K0PVNR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAoSkykIiCgan3XsHKjJJS6FlHnvvHeXQo',
    appId: '1:233214734477:android:4e3ab5f905eebe38a132c4',
    messagingSenderId: '233214734477',
    projectId: 'stegx-607ce',
    authDomain: 'stegx-607ce.firebaseapp.com',
    storageBucket: 'stegx-607ce.firebasestorage.app',
  );
}
