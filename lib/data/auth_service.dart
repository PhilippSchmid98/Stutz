import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/core/constants/firebase_config.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      dev.log('Anonymous login failed', error: e, name: 'AuthService');
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    // Initialize GoogleSignIn lazily — re-calling initialize() on the singleton
    // can reset state mid-flight and cause spurious cancellation errors.
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: FirebaseConfig.googleSignInWebClientId,
      );
      _googleInitialized = true;
    }

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Retrieve authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      // User deliberately canceled the picker — suppress the error silently.
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        dev.log('Google sign-in canceled by user', name: 'AuthService');
        return null;
      }
      dev.log('Google login failed', error: e, name: 'AuthService');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}
