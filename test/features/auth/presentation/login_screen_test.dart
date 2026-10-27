import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('uses the app theme and a branded Google button', (tester) async {
    final theme = ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFBF9F9),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006565)),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _RecordingAuthController()),
        ],
        child: MaterialApp(theme: theme, home: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull);
    final button = tester.widget<OutlinedButton>(
      find.byWidgetPredicate((widget) => widget is OutlinedButton),
    );
    expect(button.style!.backgroundColor!.resolve({}), Colors.white);
    expect(button.style!.side!.resolve({})!.color, const Color(0xFF747775));
    final logo = tester.widget<Image>(find.byType(Image));
    expect(
      (logo.image as AssetImage).assetName,
      'assets/branding/google_g.png',
    );
    expect(logo.excludeFromSemantics, isTrue);
    expect(find.byIcon(Icons.g_mobiledata), findsNothing);
  });

  testWidgets('both sign-in options remain available on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _RecordingAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(() => controller)],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final google = find.text('Mit Google fortfahren');
    await tester.ensureVisible(google);
    await tester.tap(google);
    await tester.pump();
    expect(controller.googleCalls, 1);

    final guest = find.text('Ohne Account fortfahren (Gast)');
    await tester.ensureVisible(guest);
    await tester.tap(guest);
    await tester.pump();
    expect(controller.guestCalls, 1);
    expect(tester.takeException(), isNull);
  });
}

class _RecordingAuthController extends AuthController {
  int googleCalls = 0;
  int guestCalls = 0;

  @override
  Future<User?> signInWithGoogle() async {
    googleCalls++;
    return null;
  }

  @override
  Future<User?> signInAnonymously() async {
    guestCalls++;
    return null;
  }
}
