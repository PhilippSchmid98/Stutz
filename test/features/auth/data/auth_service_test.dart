import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/auth/data/auth_service.dart';

void main() {
  group('GoogleAccountLinkCoordinator', () {
    final credential = GoogleAuthProvider.credential(idToken: 'test-token');

    test('preserves the anonymous Firebase user ID', () async {
      final coordinator = GoogleAccountLinkCoordinator(
        expectedUserId: 'anonymous-user',
        selectCredential: ({required chooseAnotherAccount}) async {
          expect(chooseAnotherAccount, isFalse);
          return credential;
        },
        linkCredential: (_) async => 'anonymous-user',
      );

      expect(await coordinator.link(), GoogleAccountLinkResult.linked);
    });

    test('returns canceled without attempting to link', () async {
      var linkCalls = 0;
      final coordinator = GoogleAccountLinkCoordinator(
        expectedUserId: 'anonymous-user',
        selectCredential: ({required chooseAnotherAccount}) async => null,
        linkCredential: (_) async {
          linkCalls++;
          return 'anonymous-user';
        },
      );

      expect(await coordinator.link(), GoogleAccountLinkResult.canceled);
      expect(linkCalls, 0);
    });

    test('reports a credential that belongs to another account', () async {
      final coordinator = GoogleAccountLinkCoordinator(
        expectedUserId: 'anonymous-user',
        selectCredential: ({required chooseAnotherAccount}) async => credential,
        linkCredential: (_) async =>
            throw FirebaseAuthException(code: 'credential-already-in-use'),
      );

      expect(
        await coordinator.link(),
        GoogleAccountLinkResult.credentialAlreadyInUse,
      );
    });

    test('requests another Google account without changing the UID', () async {
      final coordinator = GoogleAccountLinkCoordinator(
        expectedUserId: 'anonymous-user',
        selectCredential: ({required chooseAnotherAccount}) async {
          expect(chooseAnotherAccount, isTrue);
          return credential;
        },
        linkCredential: (_) async => 'anonymous-user',
      );

      expect(
        await coordinator.link(chooseAnotherAccount: true),
        GoogleAccountLinkResult.linked,
      );
    });

    test('rejects a link result with a different Firebase user ID', () async {
      final coordinator = GoogleAccountLinkCoordinator(
        expectedUserId: 'anonymous-user',
        selectCredential: ({required chooseAnotherAccount}) async => credential,
        linkCredential: (_) async => 'different-user',
      );

      await expectLater(coordinator.link(), throwsStateError);
    });
  });

  test('Firebase sign-out still runs when Google cleanup fails', () async {
    final calls = <String>[];
    final service = AuthService(
      signOutCoordinator: AuthSignOutCoordinator(
        googleSignOut: () async {
          calls.add('google');
          throw StateError('Google unavailable');
        },
        firebaseSignOut: () async {
          calls.add('firebase');
        },
      ),
    );

    await service.signOut();

    expect(calls, ['google', 'firebase']);
  });

  test('Firebase sign-out failures remain visible to the caller', () async {
    final firebaseError = StateError('Firebase unavailable');
    final service = AuthService(
      signOutCoordinator: AuthSignOutCoordinator(
        googleSignOut: () async {},
        firebaseSignOut: () async => throw firebaseError,
      ),
    );

    await expectLater(service.signOut(), throwsA(same(firebaseError)));
  });

  test('Firebase failure wins when both sign-out actions fail', () async {
    final firebaseError = StateError('Firebase unavailable');
    var firebaseCalls = 0;
    final service = AuthService(
      signOutCoordinator: AuthSignOutCoordinator(
        googleSignOut: () async => throw StateError('Google unavailable'),
        firebaseSignOut: () async {
          firebaseCalls++;
          throw firebaseError;
        },
      ),
    );

    await expectLater(service.signOut(), throwsA(same(firebaseError)));
    expect(firebaseCalls, 1);
  });
}
