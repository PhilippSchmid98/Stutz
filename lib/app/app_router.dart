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
      loading: () => const _SplashScreen(),
      error: (_, __) => _RouterErrorScreen(
        message: 'Die Anmeldung konnte nicht geladen werden.',
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (user) =>
          user == null ? const _SignedOutRouter() : const HomeScreen(),
    );
  }
}

class _SignedOutRouter extends ConsumerWidget {
  const _SignedOutRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(seenOnboardingProvider);

    return onboardingAsync.when(
      loading: () => const _SplashScreen(),
      error: (_, __) => _RouterErrorScreen(
        message: 'Die App-Einstellungen konnten nicht geladen werden.',
        onRetry: () => ref.invalidate(seenOnboardingProvider),
      ),
      data: (seen) => seen ? const LoginScreen() : const WelcomeScreen(),
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

class _RouterErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RouterErrorScreen({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
