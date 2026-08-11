import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/app/home_screen.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/presentation/login_screen.dart';
import 'package:stutz/features/auth/presentation/welcome_screen.dart';

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

    // Detect involuntary logouts (e.g. account disabled in Firebase Console).
    // If the transition from signed-in → signed-out was NOT voluntary, show a
    // message so the user knows what happened before hitting the login screen.
    ref.listen(authStateProvider, (previous, next) {
      final wasSignedIn = previous?.asData?.value != null;
      final isSignedOut = next is AsyncData && next.value == null;

      if (wasSignedIn && isSignedOut) {
        final isVoluntary = ref.read(voluntarySignOutProvider);
        if (!isVoluntary) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Es gab ein Problem. Bitte melde dich erneut an.'),
            ),
          );
        }
        // Always reset the flag after the transition is handled.
        ref.read(voluntarySignOutProvider.notifier).setVoluntary(false);
      }
    });

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
