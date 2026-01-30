import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/data/auth_service.dart';
import 'package:stutz/presentation/screens/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  // Wenn Login erfolgreich: Flag speichern und zum Dashboard
  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ), // Hier dein Ziel-Screen
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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

              if (_isLoading)
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
                      setState(() => _isLoading = true);
                      // Hier rufen wir deine gefixte AuthService Methode auf
                      final user = await ref
                          .read(authServiceProvider)
                          .signInWithGoogle();

                      if (user != null) {
                        await _onLoginSuccess();
                      } else {
                        setState(() => _isLoading = false);
                        // Optional: SnackBar mit Fehlermeldung anzeigen
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
                      setState(() => _isLoading = true);
                      final user = await ref
                          .read(authServiceProvider)
                          .signInAnonymously();
                      if (user != null) {
                        await _onLoginSuccess();
                      } else {
                        setState(() => _isLoading = false);
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
