import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/core/constants/firebase_config.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Access GoogleSignIn instance via Singleton
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      dev.log('Anonymous login failed', error: e, name: 'AuthService');
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    // Initialize GoogleSignIn with Firebase server client ID
    await _googleSignIn.initialize(
      serverClientId: FirebaseConfig.googleSignInWebClientId,
    );

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
      dev.log('Google login failed', error: e, name: 'AuthService');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}
