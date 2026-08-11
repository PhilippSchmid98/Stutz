/// Firebase / Google Sign-In configuration constants.
///
/// Centralised so that the OAuth client ID is not scattered across
/// service classes and is easy to rotate without touching business logic.
class FirebaseConfig {
  const FirebaseConfig._();

  /// Google Sign-In OAuth 2.0 Web Client ID (server client ID).
  /// Used by [GoogleSignIn.initialize] to obtain a server-side id_token
  /// that Firebase Auth can verify.
  static const String googleSignInWebClientId =
      '78877647203-vc4uh88pqqb317ied0apm4tckkpk0bbi.apps.googleusercontent.com';
}
