import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stutz/core/theme/app_theme.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);

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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 64).clamp(
                  0.0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('Anmelden', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(
                        'Speichere deine Daten sicher in der Cloud.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1F1F1F),
                              side: const BorderSide(color: Color(0xFF747775)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Google Sans',
                                fontFamilyFallback: ['Roboto'],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.25,
                              ),
                            ),
                            icon: Image.asset(
                              'assets/branding/google_g.png',
                              width: 20,
                              height: 20,
                              excludeFromSemantics: true,
                            ),
                            label: const Text('Mit Google fortfahren'),
                            onPressed: () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextButton(
                          label: 'Ohne Account fortfahren (Gast)',
                          foregroundColor: theme.colorScheme.primary,
                          textStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }
}
