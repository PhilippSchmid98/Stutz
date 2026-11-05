import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/data/auth_service.dart';
import 'package:stutz/features/notification_import/application/notification_capture_gateway.dart';
import 'package:stutz/features/notification_import/application/notification_capture_providers.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

void main() {
  test(
    'anonymous Google linking forwards the account selection result',
    () async {
      final chooseAnotherValues = <bool>[];
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(
            AuthService(
              googleAccountLinkAction: ({required chooseAnotherAccount}) async {
                chooseAnotherValues.add(chooseAnotherAccount);
                return GoogleAccountLinkResult.credentialAlreadyInUse;
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(authControllerProvider.notifier)
          .linkAnonymousUserWithGoogle(chooseAnotherAccount: true);

      expect(result, GoogleAccountLinkResult.credentialAlreadyInUse);
      expect(chooseAnotherValues, [true]);
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
    },
  );

  test('anonymous Google linking exposes retryable errors', () async {
    final linkError = StateError('Google unavailable');
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(
          AuthService(
            googleAccountLinkAction: ({required chooseAnotherAccount}) async =>
                throw linkError,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .linkAnonymousUserWithGoogle(),
      throwsA(same(linkError)),
    );

    final state = container.read(authControllerProvider);
    expect(state, isA<AsyncError<void>>());
    expect(state.error, same(linkError));
  });

  test(
    'Google cleanup failure still clears owner and signs out of Firebase',
    () async {
      final calls = <String>[];
      final container = _container(
        calls: calls,
        googleSignOut: () async {
          calls.add('google');
          throw StateError('Google unavailable');
        },
        firebaseSignOut: () async {
          calls.add('firebase');
        },
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signOut();

      expect(calls, ['native-owner', 'google', 'firebase']);
      expect(
        container.read(authControllerProvider),
        const AsyncData<void>(null),
      );
      expect(container.read(voluntarySignOutProvider), isTrue);
    },
  );

  test('native cleanup failure does not block Firebase sign-out', () async {
    final calls = <String>[];
    final container = _container(
      calls: calls,
      nativeCleanupError: StateError('Platform unavailable'),
      googleSignOut: () async {
        calls.add('google');
      },
      firebaseSignOut: () async {
        calls.add('firebase');
      },
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.notifier).signOut();

    expect(calls, ['native-owner', 'google', 'firebase']);
    expect(container.read(authControllerProvider), const AsyncData<void>(null));
  });

  test(
    'Firebase failure remains retryable and resets voluntary state',
    () async {
      final calls = <String>[];
      final firebaseError = StateError('Firebase unavailable');
      final container = _container(
        calls: calls,
        googleSignOut: () async {
          calls.add('google');
        },
        firebaseSignOut: () async {
          calls.add('firebase');
          throw firebaseError;
        },
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(authControllerProvider.notifier).signOut(),
        throwsA(same(firebaseError)),
      );

      expect(calls, ['native-owner', 'google', 'firebase']);
      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncError<void>>());
      expect(state.error, same(firebaseError));
      expect(container.read(voluntarySignOutProvider), isFalse);
    },
  );
}

ProviderContainer _container({
  required List<String> calls,
  required Future<void> Function() googleSignOut,
  required Future<void> Function() firebaseSignOut,
  Object? nativeCleanupError,
}) {
  final authService = AuthService(
    signOutCoordinator: AuthSignOutCoordinator(
      googleSignOut: googleSignOut,
      firebaseSignOut: firebaseSignOut,
    ),
  );
  final captureGateway = _FakeCaptureGateway(
    calls: calls,
    clearError: nativeCleanupError,
  );
  return ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(authService),
      notificationCaptureGatewayProvider.overrideWithValue(captureGateway),
    ],
  );
}

class _FakeCaptureGateway implements NotificationCaptureGateway {
  final List<String> calls;
  final Object? clearError;

  const _FakeCaptureGateway({required this.calls, this.clearError});

  @override
  bool get isSupported => true;

  @override
  Stream<void> get draftCapturedEvents => const Stream.empty();

  @override
  Future<void> acknowledgeSyncedDrafts(List<String> draftIds) async {}

  @override
  Future<void> captureActiveNotifications() async {}

  @override
  Future<void> clearActiveOwner() async {
    calls.add('native-owner');
    if (clearError != null) throw clearError!;
  }

  @override
  Future<bool> hasNotificationAccess() async => true;

  @override
  Future<List<TransactionDraft>> listUnsyncedDrafts() async => const [];

  @override
  Future<void> openNotificationAccessSettings() async {}

  @override
  Future<void> setActiveOwner(String userId) async {}
}
