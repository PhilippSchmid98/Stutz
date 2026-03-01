import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
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
          'DefaultFirebaseOptions have not been configured for Linux. '
          'Reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDU61E7IL8hSpfnN9pGgt8HLpDMIKocS60',
    appId: '1:78877647203:web:44c04b3797875ba88c3356',
    messagingSenderId: '78877647203',
    projectId: 'stutz-7ed90',
    authDomain: 'stutz-7ed90.firebaseapp.com',
    storageBucket: 'stutz-7ed90.firebasestorage.app',
    measurementId: 'G-RQTCTK8LLM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUuXNMtECCBLvICmFlNx5Vnb27Sx8yS6M',
    appId: '1:78877647203:android:0ea6a4ff3a57399f8c3356',
    messagingSenderId: '78877647203',
    projectId: 'stutz-7ed90',
    storageBucket: 'stutz-7ed90.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsx06ZrpHWpqz2rvqsHhlXia7GymEWCBg',
    appId: '1:78877647203:ios:1a9438fec5e102c88c3356',
    messagingSenderId: '78877647203',
    projectId: 'stutz-7ed90',
    storageBucket: 'stutz-7ed90.firebasestorage.app',
    androidClientId:
        '78877647203-90bkqm8dde7srh36cure9v9bk1su4jqu.apps.googleusercontent.com',
    iosClientId:
        '78877647203-gmjvometrj0jtjrugpv14s3ldsbo5qfo.apps.googleusercontent.com',
    iosBundleId: 'ch.stutz.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsx06ZrpHWpqz2rvqsHhlXia7GymEWCBg',
    appId: '1:78877647203:ios:0434a955f1371a9b8c3356',
    messagingSenderId: '78877647203',
    projectId: 'stutz-7ed90',
    storageBucket: 'stutz-7ed90.firebasestorage.app',
    androidClientId:
        '78877647203-90bkqm8dde7srh36cure9v9bk1su4jqu.apps.googleusercontent.com',
    iosClientId:
        '78877647203-l72cgbc9kk6nsph5s6eq0da90o3795la.apps.googleusercontent.com',
    iosBundleId: 'com.example.expenseTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDU61E7IL8hSpfnN9pGgt8HLpDMIKocS60',
    appId: '1:78877647203:web:5959ec978ae0ccda8c3356',
    messagingSenderId: '78877647203',
    projectId: 'stutz-7ed90',
    authDomain: 'stutz-7ed90.firebaseapp.com',
    storageBucket: 'stutz-7ed90.firebasestorage.app',
    measurementId: 'G-PN322RJLP5',
  );
}
