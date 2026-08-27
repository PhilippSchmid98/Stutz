import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/app/app_loading_screen.dart';
import 'package:stutz/main.dart';

void main() {
  testWidgets('shows an in-app loading screen while Firebase initializes', (
    tester,
  ) async {
    final initialization = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        child: MainApp(initializeFirebase: () => initialization.future),
      ),
    );

    expect(find.byType(AppLoadingScreen), findsOneWidget);
    expect(find.text('Stutz wird gestartet'), findsOneWidget);

    initialization.complete();
    await tester.pump();
  });

  testWidgets('retries Firebase initialization after a failure', (
    tester,
  ) async {
    var attempts = 0;

    Future<void> initializeFirebase() {
      attempts += 1;
      if (attempts == 1) return Future<void>.error(StateError('offline'));
      return Future<void>.value();
    }

    await tester.pumpWidget(
      ProviderScope(child: MainApp(initializeFirebase: initializeFirebase)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppInitializationErrorScreen), findsOneWidget);
    expect(attempts, 1);

    await tester.tap(find.text('Erneut versuchen'));
    await tester.pump();

    expect(attempts, 2);
  });
}
