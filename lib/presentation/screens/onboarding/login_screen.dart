import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/data/auth_service.dart';
import 'package:stutz/presentation/screens/home_screen.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    Future<void> onLoginSuccess() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }

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

              if (isLoading.value)
                const CircularProgressIndicator()
              else ...[
                // GOOGLE LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 32,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "Mit Google fortfahren",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    onPressed: () async {
                      isLoading.value = true;
                      final user = await ref
                          .read(authServiceProvider)
                          .signInWithGoogle();

                      if (user != null) {
                        await onLoginSuccess();
                      } else {
                        isLoading.value = false;
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // GAST LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () async {
                      isLoading.value = true;
                      final user = await ref
                          .read(authServiceProvider)
                          .signInAnonymously();
                      if (user != null) {
                        await onLoginSuccess();
                      } else {
                        isLoading.value = false;
                      }
                    },
                    child: Text(
                      "Ohne Account fortfahren (Gast)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
