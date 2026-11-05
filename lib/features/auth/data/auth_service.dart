import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

const _googleSignInWebClientId =
    '78877647203-vc4uh88pqqb317ied0apm4tckkpk0bbi.apps.googleusercontent.com';

enum GoogleAccountLinkResult { linked, canceled, credentialAlreadyInUse }

typedef GoogleAccountLinkAction =
    Future<GoogleAccountLinkResult> Function({
      required bool chooseAnotherAccount,
    });

class GoogleAccountLinkCoordinator {
  final String _expectedUserId;
  final Future<AuthCredential?> Function({required bool chooseAnotherAccount})
  _selectCredential;
  final Future<String> Function(AuthCredential credential) _linkCredential;

  const GoogleAccountLinkCoordinator({
    required String expectedUserId,
    required Future<AuthCredential?> Function({
      required bool chooseAnotherAccount,
    })
    selectCredential,
    required Future<String> Function(AuthCredential credential) linkCredential,
  }) : _expectedUserId = expectedUserId,
       _selectCredential = selectCredential,
       _linkCredential = linkCredential;

  Future<GoogleAccountLinkResult> link({
    bool chooseAnotherAccount = false,
  }) async {
    final credential = await _selectCredential(
      chooseAnotherAccount: chooseAnotherAccount,
    );
    if (credential == null) return GoogleAccountLinkResult.canceled;

    try {
      final linkedUserId = await _linkCredential(credential);
      if (linkedUserId != _expectedUserId) {
        throw StateError('Google linking changed the Firebase user ID');
      }
      return GoogleAccountLinkResult.linked;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use') {
        return GoogleAccountLinkResult.credentialAlreadyInUse;
      }
      rethrow;
    }
  }
}

class AuthSignOutCoordinator {
  final Future<void> Function() _googleSignOut;
  final Future<void> Function() _firebaseSignOut;

  const AuthSignOutCoordinator({
    required Future<void> Function() googleSignOut,
    required Future<void> Function() firebaseSignOut,
  }) : _googleSignOut = googleSignOut,
       _firebaseSignOut = firebaseSignOut;

  Future<void> signOut() async {
    try {
      await _googleSignOut();
    } catch (_) {
      dev.log('Google sign-out cleanup failed', name: 'AuthService');
    }
    await _firebaseSignOut();
  }
}

class AuthService {
  final AuthSignOutCoordinator? _signOutCoordinator;
  final GoogleAccountLinkAction? _googleAccountLinkAction;

  AuthService({
    AuthSignOutCoordinator? signOutCoordinator,
    GoogleAccountLinkAction? googleAccountLinkAction,
  }) : _signOutCoordinator = signOutCoordinator,
       _googleAccountLinkAction = googleAccountLinkAction;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
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

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(serverClientId: _googleSignInWebClientId);
      _googleInitialized = true;
    }
  }

  Future<AuthCredential?> _selectGoogleCredential({
    bool chooseAnotherAccount = false,
  }) async {
    await _ensureGoogleSignInInitialized();
    if (chooseAnotherAccount) {
      await _googleSignIn.signOut();
    }

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      return GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null,
      );
    } catch (e) {
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        dev.log('Google account selection canceled', name: 'AuthService');
        return null;
      }
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final credential = await _selectGoogleCredential();
      if (credential == null) return null;
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      dev.log('Google login failed', error: e, name: 'AuthService');
      rethrow;
    }
  }

  Future<GoogleAccountLinkResult> linkAnonymousUserWithGoogle({
    bool chooseAnotherAccount = false,
  }) async {
    final injectedAction = _googleAccountLinkAction;
    if (injectedAction != null) {
      return injectedAction(chooseAnotherAccount: chooseAnotherAccount);
    }

    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw StateError('Google linking requires an anonymous user');
    }

    return GoogleAccountLinkCoordinator(
      expectedUserId: user.uid,
      selectCredential: ({required chooseAnotherAccount}) =>
          _selectGoogleCredential(chooseAnotherAccount: chooseAnotherAccount),
      linkCredential: (credential) async {
        final linkedCredential = await user.linkWithCredential(credential);
        final linkedUser = linkedCredential.user;
        if (linkedUser == null) {
          throw StateError('Google linking returned no Firebase user');
        }
        return linkedUser.uid;
      },
    ).link(chooseAnotherAccount: chooseAnotherAccount);
  }

  Future<void> signOut() async {
    final coordinator =
        _signOutCoordinator ??
        AuthSignOutCoordinator(
          googleSignOut: () async => _googleSignIn.signOut(),
          firebaseSignOut: _auth.signOut,
        );
    await coordinator.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}
