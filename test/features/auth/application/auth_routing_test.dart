import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stutz/app/app_router.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/presentation/login_screen.dart';
import 'package:stutz/features/auth/presentation/tutorial_screen.dart';
import 'package:stutz/features/auth/presentation/welcome_screen.dart';

void main() {
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
}
