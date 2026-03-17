import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/presentation/providers/auth_provider.dart';
import 'package:stutz/presentation/screens/home_screen.dart';
import 'package:stutz/presentation/screens/onboarding/login_screen.dart';
import 'package:stutz/presentation/screens/onboarding/welcome_screen.dart';

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
