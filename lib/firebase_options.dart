// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCifU83R2E7V5j9fEJe9qScdK_0OfBVWLY',
    appId: '1:800973877444:web:90b8bdf932bc9fe8c01991',
    messagingSenderId: '800973877444',
    projectId: 'swrv-e0728',
    authDomain: 'swrv-e0728.firebaseapp.com',
    storageBucket: 'swrv-e0728.appspot.com',
    measurementId: 'G-BJWBJE138H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2eYJsXk_afkBKSrCZeae2KWDiB_vsenE',
    appId: '1:800973877444:android:c74f52471323f25dc01991',
    messagingSenderId: '800973877444',
    projectId: 'swrv-e0728',
    storageBucket: 'swrv-e0728.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApcvPJmGRg2e5nMKjyk3lfRnp0RvXrHJQ',
    appId: '1:800973877444:ios:036a73f074247e34c01991',
    messagingSenderId: '800973877444',
    projectId: 'swrv-e0728',
    storageBucket: 'swrv-e0728.appspot.com',
    iosBundleId: 'com.swerv.cs.swrv',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyApcvPJmGRg2e5nMKjyk3lfRnp0RvXrHJQ',
    appId: '1:800973877444:ios:036a73f074247e34c01991',
    messagingSenderId: '800973877444',
    projectId: 'swrv-e0728',
    storageBucket: 'swrv-e0728.appspot.com',
    iosBundleId: 'com.swerv.cs.swrv',
  );
}