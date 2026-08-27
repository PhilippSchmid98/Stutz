import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/features/auth/data/auth_service.dart';

part 'auth_providers.g.dart';

/// True when the sign-out was explicitly triggered by the user.
/// When the auth stream transitions to signed-out while this is false,
/// [AppRouter] treats it as an involuntary logout (e.g. account disabled)
/// and shows an explanatory message.
@Riverpod(keepAlive: true)
class VoluntarySignOut extends _$VoluntarySignOut {
  @override
  bool build() => false;

  void setVoluntary(bool isVoluntary) {
    state = isVoluntary;
  }
}

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
/// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<User?> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authServiceProvider).signInAnonymously();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Signs out the current user and marks onboarding as seen so the app
  /// routes to [LoginScreen] (not [WelcomeScreen]) on the next cold start.
  Future<void> signOut() async {
    // Mark as voluntary before the stream emits null, so AppRouter
    // does not show the "involuntary logout" message.
    ref.read(voluntarySignOutProvider.notifier).setVoluntary(true);

    state = const AsyncLoading();
    try {
      await ref.read(authServiceProvider).signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

/// Persists completion of the device-local onboarding flow.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  Future<void> complete() async {
    state = const AsyncLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      ref.invalidate(seenOnboardingProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
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

/// Public API for other features to get the current user's id — the Auth
/// feature is the sole owner of this. Other features' repositories watch
/// this instead of touching Auth's data layer directly.
@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
}
