import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/data/auth_service.dart';
import 'package:stutz/features/auth/presentation/account_sign_out_button.dart';

void main() {
  testWidgets('a permanent account signs out without a warning', (
    tester,
  ) async {
    final controller = _TestAuthController();
    await _pumpButton(tester, controller: controller, isAnonymous: false);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pump();

    expect(controller._signOutCalls, 1);
    expect(find.text('Gastkonto schützen'), findsNothing);
  });

  testWidgets('an anonymous account can cancel and stay signed in', (
    tester,
  ) async {
    final controller = _TestAuthController();
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Gastkonto schützen'), findsOneWidget);
    expect(find.text('Mit Google sichern und abmelden'), findsOneWidget);
    expect(find.text('Trotzdem abmelden'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.textContaining('Export'), findsNothing);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(controller._signOutCalls, 0);
    expect(find.text('Gastkonto schützen'), findsNothing);
  });

  testWidgets('an anonymous account can explicitly sign out without linking', (
    tester,
  ) async {
    final controller = _TestAuthController();
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trotzdem abmelden'));
    await tester.pumpAndSettle();

    expect(controller._signOutCalls, 1);
    expect(controller._linkSelections, isEmpty);
  });

  testWidgets('successful Google linking preserves the flow and signs out', (
    tester,
  ) async {
    final controller = _TestAuthController(
      linkResults: [GoogleAccountLinkResult.linked],
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mit Google sichern und abmelden'));
    await tester.pumpAndSettle();

    expect(controller._linkSelections, [false]);
    expect(controller._signOutCalls, 1);
  });

  testWidgets('a linked credential only allows cancel or another account', (
    tester,
  ) async {
    final controller = _TestAuthController(
      linkResults: [
        GoogleAccountLinkResult.credentialAlreadyInUse,
        GoogleAccountLinkResult.linked,
      ],
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mit Google sichern und abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Google-Konto bereits verwendet'), findsOneWidget);
    expect(find.text('Anderes Google-Konto verwenden'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('Trotzdem abmelden'), findsNothing);
    expect(find.textContaining('Export'), findsNothing);

    await tester.tap(find.text('Anderes Google-Konto verwenden'));
    await tester.pumpAndSettle();

    expect(controller._linkSelections, [false, true]);
    expect(controller._signOutCalls, 1);
  });

  testWidgets('canceling Google selection keeps the warning open', (
    tester,
  ) async {
    final controller = _TestAuthController(
      linkResults: [GoogleAccountLinkResult.canceled],
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mit Google sichern und abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Gastkonto schützen'), findsOneWidget);
    expect(controller._signOutCalls, 0);
  });

  testWidgets('canceling a credential collision keeps the guest signed in', (
    tester,
  ) async {
    final controller = _TestAuthController(
      linkResults: [GoogleAccountLinkResult.credentialAlreadyInUse],
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mit Google sichern und abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(controller._signOutCalls, 0);
    expect(find.text('Google-Konto bereits verwendet'), findsNothing);
  });

  testWidgets('a linking failure leaves the guest signed in', (tester) async {
    final controller = _TestAuthController(
      linkError: StateError('Google unavailable'),
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mit Google sichern und abmelden'));
    await tester.pumpAndSettle();

    expect(
      find.text('Das Google-Konto konnte nicht verknüpft werden.'),
      findsOneWidget,
    );
    expect(controller._signOutCalls, 0);
  });

  testWidgets('a failed sign-out can be retried without losing the session', (
    tester,
  ) async {
    final controller = _TestAuthController(
      signOutErrors: [StateError('Firebase unavailable')],
    );
    await _pumpButton(tester, controller: controller);

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trotzdem abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Abmeldung fehlgeschlagen'), findsOneWidget);
    expect(find.text('Erneut abmelden'), findsOneWidget);
    expect(controller._signOutCalls, 1);

    await tester.tap(find.text('Erneut abmelden'));
    await tester.pumpAndSettle();

    expect(controller._signOutCalls, 2);
    expect(find.text('Abmeldung fehlgeschlagen'), findsNothing);
  });

  testWidgets('the warning remains usable on a narrow large-text screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _TestAuthController();
    await _pumpButton(
      tester,
      controller: controller,
      textScaler: const TextScaler.linear(2),
    );

    await tester.tap(find.byTooltip('Abmelden'));
    await tester.pumpAndSettle();

    expect(find.text('Mit Google sichern und abmelden'), findsOneWidget);
    expect(find.text('Trotzdem abmelden'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpButton(
  WidgetTester tester, {
  required _TestAuthController controller,
  bool isAnonymous = true,
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => controller),
        currentUserIsAnonymousProvider.overrideWith((ref) => isAnonymous),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: Center(child: AccountSignOutButton())),
      ),
    ),
  );
  await tester.pump();
}

class _TestAuthController extends AuthController {
  final List<GoogleAccountLinkResult> _linkResults;
  final Object? _linkError;
  final List<Object> _signOutErrors;
  final List<bool> _linkSelections = [];
  int _signOutCalls = 0;

  _TestAuthController({
    List<GoogleAccountLinkResult>? linkResults,
    Object? linkError,
    List<Object>? signOutErrors,
  }) : _linkResults = [...?linkResults],
       _linkError = linkError,
       _signOutErrors = [...?signOutErrors];

  @override
  Future<GoogleAccountLinkResult> linkAnonymousUserWithGoogle({
    bool chooseAnotherAccount = false,
  }) async {
    _linkSelections.add(chooseAnotherAccount);
    if (_linkError != null) throw _linkError;
    return _linkResults.removeAt(0);
  }

  @override
  Future<void> signOut() async {
    _signOutCalls++;
    if (_signOutErrors.isNotEmpty) throw _signOutErrors.removeAt(0);
  }
}
