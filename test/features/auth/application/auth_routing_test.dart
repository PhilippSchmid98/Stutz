import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/app/app_router.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/presentation/login_screen.dart';
import 'package:stutz/features/auth/presentation/tutorial_screen.dart';
import 'package:stutz/features/auth/presentation/welcome_screen.dart';

void main() {
  for (final skip in [true, false]) {
    testWidgets(
      'tutorial ${skip ? 'skip' : 'completion'} survives a delayed preferences write',
      (tester) async {
        SharedPreferences.resetStatic();
        const channel = MethodChannel('plugins.flutter.io/shared_preferences');
        final writeStarted = Completer<void>();
        final releaseWrite = Completer<void>();
        final values = <String, Object>{};
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async {
            switch (call.method) {
              case 'getAll':
                return values;
              case 'setBool':
                writeStarted.complete();
                await releaseWrite.future;
                values[call.arguments['key'] as String] =
                    call.arguments['value'] as bool;
                return true;
              default:
                throw MissingPluginException(
                  'Unexpected method: ${call.method}',
                );
            }
          },
        );
        addTearDown(() {
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          );
          SharedPreferences.resetStatic();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith((ref) => Stream.value(null)),
            ],
            child: const MaterialApp(home: AppRouter()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Tour starten'));
        await tester.pumpAndSettle();

        if (!skip) {
          for (var page = 0; page < 2; page++) {
            await tester.tap(find.text('Weiter'));
            await tester.pumpAndSettle();
          }
        }
        await tester.tap(find.text(skip ? 'Überspringen' : 'Alles klar'));
        await tester.pump();
        expect(writeStarted.isCompleted, isTrue);
        await tester.pump(const Duration(milliseconds: 100));
        releaseWrite.complete();
        await tester.pumpAndSettle();

        expect(values['flutter.seenOnboarding'], isTrue);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(
          find.text(
            'Die Einführung konnte nicht abgeschlossen werden. Bitte versuche es erneut.',
          ),
          findsNothing,
        );
      },
    );
  }

  group('AppRouter', () {
    testWidgets('shows splash screen while auth state is unresolved', (
      tester,
    ) async {
      final authStream = StreamController<User?>();
      addTearDown(authStream.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => authStream.stream),
          ],
          child: const MaterialApp(home: AppRouter()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('shows welcome screen before onboarding is complete', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            seenOnboardingProvider.overrideWith((ref) => Future.value(false)),
          ],
          child: const MaterialApp(home: AppRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('shows login screen after onboarding is complete', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            seenOnboardingProvider.overrideWith((ref) => Future.value(true)),
          ],
          child: const MaterialApp(home: AppRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('shows an auth retry state when auth loading fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream<User?>.error(StateError('auth failed')),
            ),
            seenOnboardingProvider.overrideWith((ref) => Future.value(false)),
          ],
          child: const MaterialApp(home: AppRouter()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Die Anmeldung konnte nicht geladen werden.'),
        findsOneWidget,
      );
      expect(find.text('Erneut versuchen'), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('shows an onboarding retry state when preferences fail', (
      tester,
    ) async {
      final onboarding = Completer<bool>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(null)),
            seenOnboardingProvider.overrideWith((ref) => onboarding.future),
          ],
          child: const MaterialApp(home: AppRouter()),
        ),
      );
      await tester.pump();
      onboarding.completeError(StateError('preferences failed'));
      await tester.pumpAndSettle();

      expect(
        find.text('Die App-Einstellungen konnten nicht geladen werden.'),
        findsOneWidget,
      );
      expect(find.text('Erneut versuchen'), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });
  });

  test(
    'onboarding completion persists and invalidates its read provider',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(onboardingControllerProvider.notifier).complete();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('seenOnboarding'), isTrue);
      expect(await container.read(seenOnboardingProvider.future), isTrue);
    },
  );

  testWidgets('tutorial skip persists onboarding completion', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TutorialScreen())),
    );

    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('seenOnboarding'), isTrue);
  });

  testWidgets('login shows one loading state while sign-in is pending', (
    tester,
  ) async {
    final controller = _BlockingAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mit Google fortfahren'));
    await tester.pump();

    expect(controller._googleCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Mit Google fortfahren'), findsNothing);
    expect(find.text('Ohne Account fortfahren (Gast)'), findsNothing);

    controller.release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('tutorial shows feedback when completion fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingControllerProvider.overrideWith(
            () => _FailingOnboardingController(),
          ),
        ],
        child: const MaterialApp(home: TutorialScreen()),
      ),
    );

    await tester.tap(find.text('Überspringen'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Die Einführung konnte nicht abgeschlossen werden. Bitte versuche es erneut.',
      ),
      findsOneWidget,
    );
    expect(find.text('Überspringen'), findsOneWidget);
  });
}

class _BlockingAuthController extends AuthController {
  final release = Completer<void>();
  int _googleCalls = 0;

  @override
  Future<User?> signInWithGoogle() async {
    _googleCalls++;
    state = const AsyncLoading();
    await release.future;
    state = const AsyncData(null);
    return null;
  }
}

class _FailingOnboardingController extends OnboardingController {
  @override
  Future<void> complete() async {
    throw StateError('completion failed');
  }
}
