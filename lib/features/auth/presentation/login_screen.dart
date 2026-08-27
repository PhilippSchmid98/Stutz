import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    // Show a SnackBar whenever a sign-in attempt fails.
    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (_, __) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Anmeldung fehlgeschlagen. Bitte versuche es erneut.',
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.black87),
              const SizedBox(height: 24),
              const Text(
                "Anmelden",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Speichere deine Daten sicher in der Cloud.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 48),

              if (isLoading)
                const CircularProgressIndicator()
              else ...[
                AppOutlinedButton(
                  label: "Mit Google fortfahren",
                  icon: Icons.g_mobiledata,
                  iconSize: 32,
                  iconColor: Colors.black,
                  textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                  onPressed: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signInWithGoogle();
                  },
                ),

                const SizedBox(height: 16),

                AppTextButton(
                  label: "Ohne Account fortfahren (Gast)",
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signInAnonymously();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
