import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/data/auth_service.dart';
import 'package:stutz/presentation/screens/home_screen.dart';
import 'package:stutz/presentation/screens/onboarding/login_screen.dart';
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';

part 'auth_provider.g.dart';

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.
@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}

/// Returns whether the user has completed the onboarding flow at least once.
@riverpod
Future<bool> seenOnboarding(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('seenOnboarding') ?? false;
}

/// Root routing widget that reacts to auth state changes automatically.
///
/// Replaces the start-screen decision previously made synchronously in [main].
/// Now the app responds in real time: signing out immediately shows the
/// welcome/login screen without requiring a restart.
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      // Still initialising the Firebase auth stream — show nothing yet.
      loading: () => const _SplashScreen(),
      error: (_, __) => const WelcomeScreen(),
      data: (user) {
        if (user != null) return const HomeScreen();

        // Not signed in — decide between login and welcome based on onboarding.
        final onboardingAsync = ref.watch(seenOnboardingProvider);
        return onboardingAsync.when(
          loading: () => const _SplashScreen(),
          error: (_, __) => const WelcomeScreen(),
          data: (seen) => seen ? const LoginScreen() : const WelcomeScreen(),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.black)),
    );
  }
}
