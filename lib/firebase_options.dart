// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVvpbY-FKsZDzo8fKug3uD0fPB6QW4CpU',
    appId: '1:899004228841:web:292d72fa7bdeb5228c7c78',
    messagingSenderId: '899004228841',
    projectId: 'dashcards-dd719',
    authDomain: 'dashcards-dd719.firebaseapp.com',
    storageBucket: 'dashcards-dd719.firebasestorage.app',
    measurementId: 'G-46QH46V1BK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5TgIT1F_21WX7M2X5eoTmxDL8Np4ugC0',
    appId: '1:899004228841:android:3f33de4b7c88e30f8c7c78',
    messagingSenderId: '899004228841',
    projectId: 'dashcards-dd719',
    storageBucket: 'dashcards-dd719.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXK_5mA7DS0n7Hhi-aIrnhqiJrp70Hg0E',
    appId: '1:899004228841:ios:0185ed04e0d7c1da8c7c78',
    messagingSenderId: '899004228841',
    projectId: 'dashcards-dd719',
    storageBucket: 'dashcards-dd719.firebasestorage.app',
    iosBundleId: 'com.example.dashcards',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXK_5mA7DS0n7Hhi-aIrnhqiJrp70Hg0E',
    appId: '1:899004228841:ios:0185ed04e0d7c1da8c7c78',
    messagingSenderId: '899004228841',
    projectId: 'dashcards-dd719',
    storageBucket: 'dashcards-dd719.firebasestorage.app',
    iosBundleId: 'com.example.dashcards',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVvpbY-FKsZDzo8fKug3uD0fPB6QW4CpU',
    appId: '1:899004228841:web:11670add0e6852d38c7c78',
    messagingSenderId: '899004228841',
    projectId: 'dashcards-dd719',
    authDomain: 'dashcards-dd719.firebaseapp.com',
    storageBucket: 'dashcards-dd719.firebasestorage.app',
    measurementId: 'G-6SQFK8F441',
  );

}