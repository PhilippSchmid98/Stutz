import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/data/auth_service.dart';

part 'auth_provider.g.dart';

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
/// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<User?> signInAnonymously() async {
    return ref.read(authServiceProvider).signInAnonymously();
  }

  Future<User?> signInWithGoogle() async {
    return ref.read(authServiceProvider).signInWithGoogle();
  }

  /// Signs out the current user and marks onboarding as seen so the app
  /// routes to [LoginScreen] (not [WelcomeScreen]) on the next cold start.
  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    await authService.signOut();
  }
}

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.
/// keepAlive: Stream darf nie unterbrochen werden, da Routing darauf basiert.
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

/// Returns whether the user has completed the onboarding flow at least once.
@riverpod
Future<bool> seenOnboarding(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('seenOnboarding') ?? false;
}
