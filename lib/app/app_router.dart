import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/app/app_loading_screen.dart';
import 'package:stutz/app/home_screen.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/presentation/login_screen.dart';
import 'package:stutz/features/auth/presentation/welcome_screen.dart';
import 'package:stutz/features/notification_import/application/notification_draft_sync.dart';
import 'package:stutz/features/notification_import/application/notification_capture_providers.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_repository.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/notification_import/presentation/transaction_draft_review_sheet.dart';

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
      loading: () => const AppLoadingScreen(message: 'Anmeldung wird geprüft'),
      error: (_, __) => _RouterErrorScreen(
        message: 'Die Anmeldung konnte nicht geladen werden.',
        onRetry: () => ref.invalidate(authStateProvider),
      ),
      data: (user) =>
          user == null ? const _SignedOutRouter() : const _AuthenticatedHome(),
    );
  }
}

class _AuthenticatedHome extends ConsumerStatefulWidget {
  const _AuthenticatedHome();

  @override
  ConsumerState<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends ConsumerState<_AuthenticatedHome>
    with WidgetsBindingObserver {
  final Set<String> _handledDraftIds = {};
  final Set<String> _deferredDraftIds = {};
  List<TransactionDraft> _latestPendingDrafts = const [];
  late final NotificationDraftSynchronizer _synchronizer;
  bool _isReviewOpen = false;
  bool _reviewIsScheduled = false;
  bool _hasCompletedStartupSync = false;
  bool _hasStartedStartupReview = false;
  Object? _startupSyncError;
  late final StreamSubscription<void> _captureEventsSubscription;
  late final ProviderSubscription<AsyncValue<List<TransactionDraft>>>
  _pendingDraftsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final gateway = ref.read(notificationCaptureGatewayProvider);
    _synchronizer = NotificationDraftSynchronizer(
      captureGateway: gateway,
      draftStore: ref.read(transactionDraftRepositoryProvider),
      onSynchronized: () {
        if (mounted) ref.invalidate(pendingTransactionDraftsProvider);
      },
    );
    _captureEventsSubscription = gateway.draftCapturedEvents.listen(
      (_) => _synchronizeInBackground(),
      onError: (_, __) {},
    );
    _pendingDraftsSubscription = ref
        .listenManual<AsyncValue<List<TransactionDraft>>>(
          pendingTransactionDraftsProvider,
          (_, next) {
            final drafts = next.asData?.value;
            if (drafts == null) return;
            _latestPendingDrafts = drafts;
            _deferredDraftIds.removeWhere(
              (id) => !drafts.any((draft) => draft.id == id),
            );
            if (mounted) setState(() {});
          },
          fireImmediately: true,
        );
    _synchronizeOnStartup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureEventsSubscription.cancel();
    _pendingDraftsSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_startupSyncError != null) {
      return _RouterErrorScreen(
        message: 'Erfasste Ausgaben konnten nicht geladen werden.',
        onRetry: _synchronizeOnStartup,
      );
    }
    if (!_hasCompletedStartupSync) {
      return const AppLoadingScreen(
        message: 'Erfasste Ausgaben werden geladen',
      );
    }
    return const HomeScreen();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasCompletedStartupSync) {
      _synchronizeInBackground();
    }
  }

  Future<void> _synchronizeOnStartup() async {
    setState(() {
      _startupSyncError = null;
      _hasCompletedStartupSync = false;
    });
    try {
      await _synchronizer.synchronize(ref.read(currentUserIdProvider)!);
      final drafts = await ref
          .read(transactionDraftRepositoryProvider)
          .getPendingDrafts();
      if (!mounted) return;
      setState(() {
        _latestPendingDrafts = drafts;
        _hasCompletedStartupSync = true;
      });
      _startStartupReviewIfNeeded();
    } catch (error) {
      if (mounted) setState(() => _startupSyncError = error);
    }
  }

  void _synchronizeInBackground() {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    _synchronizer.synchronize(userId).catchError((_) {});
  }

  void _startStartupReviewIfNeeded() {
    if (!_hasCompletedStartupSync || _hasStartedStartupReview) {
      return;
    }
    final startupDrafts = _eligibleDrafts;
    if (startupDrafts.isEmpty) return;
    _hasStartedStartupReview = true;
    _startReview(startupDrafts);
  }

  void _startReview(List<TransactionDraft> drafts) {
    if (_isReviewOpen || _reviewIsScheduled) return;

    _reviewIsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _reviewIsScheduled = false;
      if (!mounted || _isReviewOpen) return;

      _isReviewOpen = true;
      final result = await showTransactionDraftReviewSession(context, drafts);
      if (!mounted) return;

      _handledDraftIds.addAll(result.handledDraftIds);
      if (result.deferredRemainingDrafts) {
        _deferredDraftIds.addAll(
          _latestPendingDrafts
              .where((draft) => !_handledDraftIds.contains(draft.id))
              .map((draft) => draft.id),
        );
      }
      _isReviewOpen = false;
    });
  }

  List<TransactionDraft> get _eligibleDrafts => _latestPendingDrafts
      .where(
        (draft) =>
            !_handledDraftIds.contains(draft.id) &&
            !_deferredDraftIds.contains(draft.id),
      )
      .toList();
}

class _SignedOutRouter extends ConsumerWidget {
  const _SignedOutRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(seenOnboardingProvider);

    return onboardingAsync.when(
      loading: () =>
          const AppLoadingScreen(message: 'Einstellungen werden geladen'),
      error: (_, __) => _RouterErrorScreen(
        message: 'Die App-Einstellungen konnten nicht geladen werden.',
        onRetry: () => ref.invalidate(seenOnboardingProvider),
      ),
      data: (seen) => seen ? const LoginScreen() : const WelcomeScreen(),
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
