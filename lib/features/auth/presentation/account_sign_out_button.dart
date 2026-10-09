import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/data/auth_service.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';

class AccountSignOutButton extends ConsumerWidget {
  const AccountSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSigningOut = ref.watch(authControllerProvider).isLoading;
    final isAnonymous = ref.watch(currentUserIsAnonymousProvider);

    return IconButton(
      tooltip: 'Abmelden',
      icon: const Icon(Icons.logout),
      onPressed: isSigningOut
          ? null
          : () async {
              if (isAnonymous) {
                await showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AnonymousAccountSignOutDialog(),
                );
                return;
              }

              try {
                await ref.read(authControllerProvider.notifier).signOut();
              } catch (_) {
                if (context.mounted) {
                  showErrorSnackBar(
                    context,
                    'Abmeldung fehlgeschlagen. Bitte versuche es erneut.',
                  );
                }
              }
            },
    );
  }
}

enum _AnonymousSignOutStage { warning, collision, signOutFailed }

class AnonymousAccountSignOutDialog extends ConsumerStatefulWidget {
  const AnonymousAccountSignOutDialog({super.key});

  @override
  ConsumerState<AnonymousAccountSignOutDialog> createState() =>
      _AnonymousAccountSignOutDialogState();
}

class _AnonymousAccountSignOutDialogState
    extends ConsumerState<AnonymousAccountSignOutDialog> {
  _AnonymousSignOutStage _stage = _AnonymousSignOutStage.warning;
  bool _isBusy = false;
  bool _accountWasSecured = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isBusy,
      child: AlertDialog(
        scrollable: true,
        icon: Icon(_iconForStage),
        title: Text(_titleForStage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_messageForStage),
            if (_errorMessage case final message?) ...[
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_isBusy) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
        actions: _actionsForStage,
      ),
    );
  }

  IconData get _iconForStage => switch (_stage) {
    _AnonymousSignOutStage.warning => Icons.lock_outline,
    _AnonymousSignOutStage.collision => Icons.account_circle_outlined,
    _AnonymousSignOutStage.signOutFailed => Icons.error_outline,
  };

  String get _titleForStage => switch (_stage) {
    _AnonymousSignOutStage.warning => 'Gastkonto schützen',
    _AnonymousSignOutStage.collision => 'Google-Konto bereits verwendet',
    _AnonymousSignOutStage.signOutFailed => 'Abmeldung fehlgeschlagen',
  };

  String get _messageForStage => switch (_stage) {
    _AnonymousSignOutStage.warning =>
      'Deine Daten gehören zu einem temporären Gastkonto. Wenn du dich '
          'ohne Verknüpfung abmeldest, kannst du den Zugriff dauerhaft '
          'verlieren.',
    _AnonymousSignOutStage.collision =>
      'Dieses Google-Konto ist bereits mit einem anderen Stutz-Konto '
          'verknüpft. Dein Gastkonto bleibt unverändert. Wähle ein anderes '
          'Google-Konto oder brich ab.',
    _AnonymousSignOutStage.signOutFailed =>
      _accountWasSecured
          ? 'Dein Konto wurde mit Google gesichert. Du bist weiterhin '
                'angemeldet und kannst die Abmeldung erneut versuchen.'
          : 'Du bist weiterhin mit deinem Gastkonto angemeldet. Bitte versuche '
                'die Abmeldung erneut.',
  };

  List<Widget> get _actionsForStage => switch (_stage) {
    _AnonymousSignOutStage.warning => [
      TextButton(
        onPressed: _isBusy ? null : () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      TextButton(
        onPressed: _isBusy ? null : _signOutWithoutLinking,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Trotzdem abmelden'),
      ),
      FilledButton.icon(
        onPressed: _isBusy ? null : () => _linkAndSignOut(),
        icon: const Icon(Icons.link),
        label: const Text('Mit Google sichern und abmelden'),
      ),
    ],
    _AnonymousSignOutStage.collision => [
      TextButton(
        onPressed: _isBusy ? null : () => Navigator.pop(context),
        child: const Text('Abbrechen'),
      ),
      FilledButton.icon(
        onPressed: _isBusy
            ? null
            : () => _linkAndSignOut(chooseAnotherAccount: true),
        icon: const Icon(Icons.switch_account_outlined),
        label: const Text('Anderes Google-Konto verwenden'),
      ),
    ],
    _AnonymousSignOutStage.signOutFailed => [
      TextButton(
        onPressed: _isBusy ? null : () => Navigator.pop(context),
        child: const Text('Schließen'),
      ),
      FilledButton.icon(
        onPressed: _isBusy ? null : _retrySignOut,
        icon: const Icon(Icons.logout),
        label: const Text('Erneut abmelden'),
      ),
    ],
  };

  Future<void> _linkAndSignOut({bool chooseAnotherAccount = false}) async {
    _setBusy();
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .linkAnonymousUserWithGoogle(
            chooseAnotherAccount: chooseAnotherAccount,
          );
      if (!mounted) return;

      switch (result) {
        case GoogleAccountLinkResult.linked:
          _accountWasSecured = true;
          await _completeSignOut();
        case GoogleAccountLinkResult.canceled:
          setState(() => _isBusy = false);
        case GoogleAccountLinkResult.credentialAlreadyInUse:
          setState(() {
            _stage = _AnonymousSignOutStage.collision;
            _isBusy = false;
          });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _errorMessage = 'Das Google-Konto konnte nicht verknüpft werden.';
      });
    }
  }

  Future<void> _signOutWithoutLinking() async {
    _setBusy();
    await _completeSignOut();
  }

  Future<void> _retrySignOut() async {
    _setBusy();
    await _completeSignOut();
  }

  Future<void> _completeSignOut() async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stage = _AnonymousSignOutStage.signOutFailed;
        _isBusy = false;
      });
    }
  }

  void _setBusy() {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
  }
}
