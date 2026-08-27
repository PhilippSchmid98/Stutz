import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/theme/app_theme.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';
import 'package:stutz/shared/widgets/async_state_view.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';
import 'package:stutz/shared/widgets/styled_dropdown.dart';
import 'package:stutz/shared/widgets/styled_field_decoration.dart';
import 'package:stutz/shared/widgets/styled_text_field.dart';

void main() {
  testWidgets('styled text field keeps the budget field contract', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StyledTextField(
            controller: controller,
            label: 'Name',
            icon: Icons.label_outline,
          ),
        ),
      ),
    );

    final decoration = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration;
    final focusedBorder = decoration.focusedBorder! as OutlineInputBorder;

    expect(decoration.labelText, 'Name');
    expect(focusedBorder.borderSide.color, AppTheme.primary);
    expect(focusedBorder.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('styled text field supports the transaction field variant', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StyledTextField(
            controller: controller,
            label: 'Notiz',
            variant: StyledFieldVariant.transaction,
            maxLines: 2,
            enabled: false,
          ),
        ),
      ),
    );

    final decoration = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration;

    final focusedBorder = decoration.focusedBorder! as OutlineInputBorder;
    expect(focusedBorder.borderSide.color, AppTheme.primary);
  });

  testWidgets('styled dropdown uses the shared field decoration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StyledDropdown<String>(
            value: 'monthly',
            items: const {'monthly': 'Monatlich'},
            label: 'Intervall',
            icon: Icons.calendar_today,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Intervall'), findsOneWidget);
    expect(find.text('Monatlich'), findsOneWidget);
  });

  testWidgets('shared action buttons preserve their fixed height defaults', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppPrimaryButton(label: 'Speichern', onPressed: () {}),
              AppOutlinedButton(label: 'Abbrechen', onPressed: () {}),
              AppTextButton(label: 'Überspringen', onPressed: () {}),
              AppDestructiveButton(label: 'Löschen', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)), const Size(800, 56));
    expect(find.text('Speichern'), findsOneWidget);
    expect(find.text('Abbrechen'), findsOneWidget);
    expect(find.text('Überspringen'), findsOneWidget);
    expect(find.text('Löschen'), findsOneWidget);
  });

  testWidgets(
    'async state view renders data, loading, and friendly error states',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateView<int>(
              state: const AsyncData(42),
              errorMessage: 'Daten konnten nicht geladen werden.',
              builder: (value) => Text('Wert: $value'),
            ),
          ),
        ),
      );
      expect(find.text('Wert: 42'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateView<int>(
              state: AsyncLoading(),
              errorMessage: 'Daten konnten nicht geladen werden.',
              builder: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncStateView<int>(
              state: AsyncError(StateError('hidden detail'), StackTrace.empty),
              errorMessage: 'Daten konnten nicht geladen werden.',
              builder: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      expect(find.text('Daten konnten nicht geladen werden.'), findsOneWidget);
      expect(find.text('hidden detail'), findsNothing);
    },
  );

  testWidgets('confirmation helper returns the selected result', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final confirmed = await showConfirmationDialog(
                  context: context,
                  title: 'Löschen?',
                  content: 'Wirklich löschen?',
                  confirmLabel: 'Löschen',
                );
                if (context.mounted && confirmed == true) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Bestätigt')));
                }
              },
              child: const Text('Öffnen'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Öffnen'));
    await tester.pumpAndSettle();
    expect(find.text('Wirklich löschen?'), findsOneWidget);

    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('Bestätigt'), findsOneWidget);
  });
}
