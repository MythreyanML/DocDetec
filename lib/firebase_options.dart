// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDjn6D2MIelGDwnleVX3kXausuz5slswKY',
    appId: '1:489321981801:web:821d8266c36a1a86213ff8',
    messagingSenderId: '489321981801',
    projectId: 'doctor-finder-b94c2',
    authDomain: 'doctor-finder-b94c2.firebaseapp.com',
    storageBucket: 'doctor-finder-b94c2.firebasestorage.app',
    measurementId: 'G-T0KDWWM1BE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh1imOC3zSroryJFRAxd4i241y94F3TEc',
    appId: '1:503534317679:android:942059422f033c10721d9a',
    messagingSenderId: '503534317679',
    projectId: 'docdetec',
    storageBucket: 'docdetec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC35bOthY3dII2M5RrL0AGWHY3ZZNZJ1Fo',
    appId: '1:503534317679:ios:b03b8a63c7dc54fb721d9a',
    messagingSenderId: '503534317679',
    projectId: 'docdetec',
    storageBucket: 'docdetec.firebasestorage.app',
    iosBundleId: 'com.example.doctorFinder',
  );

  
}