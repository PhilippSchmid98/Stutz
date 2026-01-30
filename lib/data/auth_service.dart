import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // V7: Zugriff über Singleton
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error Anonymous Login: $e");
      }
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    const webClientId =
        "78877647203-vc4uh88pqqb317ied0apm4tckkpk0bbi.apps.googleusercontent.com";

    // WICHTIG: Einmalig initialisieren und den Server (Firebase) nennen
    // Das behebt den "serverClientId must be provided" Fehler
    await _googleSignIn.initialize(serverClientId: webClientId);

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Auth-Details holen
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Credential für Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null,
      );

      // Bei Firebase einloggen
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print("Error Google Login: $e");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(); // signOut existiert weiterhin
    await _auth.signOut();
  }
}

@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}
