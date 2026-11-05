import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stutz/core/connectivity/connectivity_provider.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/application/dashboard_providers.dart';
import 'package:stutz/features/dashboard/presentation/dashboard_pace_widgets.dart';
import 'package:stutz/features/dashboard/presentation/dashboard_screen.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/transactions/data/transaction_repository.dart';

import '../../../helpers/test_data.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  for (final width in [320.0, 390.0]) {
    testWidgets('keeps annual amounts on one line at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = TransactionRepository(
        'test-user',
        FakeFirebaseFirestore(),
      );
      final asOf = DateTime(2024, 7, 1);
      const name = 'Lebensmittel und Haushaltsbedarf';
      const amount = '5526.84 CHF / 7200.00 CHF';
      await repository.addTransaction(
        makeTransaction(
          id: 'purchase',
          expenseNodeId: 'food',
          amountMinor: 552684,
          dateTime: DateTime.utc(2024, 7, 1, 10),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionRepositoryProvider.overrideWithValue(repository),
            expenseTreeProvider.overrideWith(
              (ref) => Stream.value([
                makeExpense(id: 'food', name: name, plannedAmountMinor: 60000),
              ]),
            ),
            dashboardTodayProvider.overrideWith((ref) => Stream.value(asOf)),
            isOfflineProvider.overrideWith((ref) => false),
            pendingTransactionDraftsProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Jahresbilanz · 2024'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final card = find.ancestor(
        of: find.text('Jahresbilanz · 2024'),
        matching: find.byType(Card),
      );
      final nameFinder = find.descendant(of: card, matching: find.text(name));
      final pair = find.descendant(
        of: card,
        matching: find.byType(DashboardAmountPair),
      );
      final value = find.descendant(of: pair, matching: find.text(amount));
      expect(nameFinder, findsOneWidget);
      expect(pair, findsOneWidget);
      expect(value, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(value);
      expect(paragraph.didExceedMaxLines, isFalse);
      final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: amount.length),
      );
      expect(boxes, hasLength(1));
      expect(boxes.single.right, lessThanOrEqualTo(paragraph.size.width + 0.5));
      expect(
        tester.getRect(nameFinder).right,
        lessThanOrEqualTo(tester.getRect(pair).left),
      );

      final allCategories = find.descendant(
        of: card,
        matching: find.text('Alle Kategorien'),
      );
      await tester.ensureVisible(allCategories);
      await tester.pumpAndSettle();
      await tester.tap(allCategories);
      await tester.pumpAndSettle();
      final detailPair = find.byType(DashboardAmountPair);
      expect(detailPair, findsOneWidget);
      final detailParagraph = tester.renderObject<RenderParagraph>(
        find.text(amount),
      );
      expect(detailParagraph.didExceedMaxLines, isFalse);
      expect(
        detailParagraph.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: amount.length),
        ),
        hasLength(1),
      );
      expect(
        tester.getRect(find.text(name)).right,
        lessThanOrEqualTo(tester.getRect(detailPair).left),
      );
    });

    testWidgets(
      'keeps monthly and yearly card amounts on one line at $width px',
      (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repository = TransactionRepository(
          'test-user',
          FakeFirebaseFirestore(),
        );
        final asOf = DateTime(2024, 7, 1);
        const amount = '5526.84 CHF / 7200.00 CHF';
        for (final id in ['monthly', 'yearly']) {
          await repository.addTransaction(
            makeTransaction(
              id: 'purchase-$id',
              expenseNodeId: id,
              amountMinor: 552684,
              dateTime: DateTime.utc(2024, 7, 1, 10),
            ),
          );
        }

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              transactionRepositoryProvider.overrideWithValue(repository),
              expenseTreeProvider.overrideWith(
                (ref) => Stream.value([
                  makeExpense(
                    id: 'monthly',
                    name: 'Monatliche Lebenshaltungskosten',
                    plannedAmountMinor: 720000,
                  ),
                  makeExpense(
                    id: 'yearly',
                    name: 'Jährliche Versicherungsbeiträge',
                    plannedAmountMinor: 720000,
                    interval: PaymentInterval.yearly,
                  ),
                ]),
              ),
              dashboardTodayProvider.overrideWith((ref) => Stream.value(asOf)),
              isOfflineProvider.overrideWith((ref) => false),
              pendingTransactionDraftsProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(DashboardScreen)),
        );
        container
            .read(dashboardSelectedMonthProvider.notifier)
            .select(DateTime.utc(2024, 7, 1, 12));
        await tester.pumpAndSettle();

        for (final entry in [
          ('Monatlich', 'Monatliche Lebenshaltungskosten'),
          ('Jährlich · 2024', 'Jährliche Versicherungsbeiträge'),
        ]) {
          final card = find.ancestor(
            of: find.text(entry.$1),
            matching: find.byType(Card),
          );
          final name = find.descendant(of: card, matching: find.text(entry.$2));
          final pair = find.descendant(
            of: card,
            matching: find.byType(DashboardAmountPair),
          );
          final value = find.descendant(of: pair, matching: find.text(amount));
          expect(name, findsOneWidget);
          expect(pair, findsOneWidget);
          expect(value, findsOneWidget);
          final paragraph = tester.renderObject<RenderParagraph>(value);
          expect(paragraph.didExceedMaxLines, isFalse);
          final boxes = paragraph.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: amount.length),
          );
          expect(boxes, hasLength(1));
          expect(
            boxes.single.right,
            lessThanOrEqualTo(paragraph.size.width + 0.5),
          );
          expect(
            tester.getRect(name).right,
            lessThanOrEqualTo(tester.getRect(pair).left),
          );
        }
      },
    );
  }

  testWidgets(
    'shows current-year pace and matching live category transactions',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final firestore = FakeFirebaseFirestore();
      final repository = TransactionRepository('test-user', firestore);
      final asOf = DateTime(2024, 7, 1);
      final roots = [
        makeExpense(
          id: 'group',
          name: 'Haushalt',
          plannedAmountMinor: null,
          type: null,
          interval: null,
          children: [
            makeExpense(
              id: 'food',
              name: 'Lebensmittel',
              plannedAmountMinor: 10000,
            ),
            makeExpense(
              id: 'annual',
              name: 'Reisen',
              plannedAmountMinor: 20000,
              interval: PaymentInterval.yearly,
            ),
          ],
        ),
      ];
      await repository.addTransaction(
        makeTransaction(
          id: 'january',
          expenseNodeId: 'food',
          amountMinor: 10000,
          dateTime: DateTime.utc(2024, 1, 15, 12),
          note: 'January',
        ),
      );
      await repository.addTransaction(
        makeTransaction(
          id: 'today',
          expenseNodeId: 'food',
          amountMinor: 20000,
          dateTime: DateTime.utc(2024, 7, 1, 10),
          note: 'Today',
        ),
      );
      await repository.addTransaction(
        makeTransaction(
          id: 'tomorrow',
          expenseNodeId: 'food',
          amountMinor: 99900,
          dateTime: DateTime.utc(2024, 7, 1, 22),
          note: 'Tomorrow',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionRepositoryProvider.overrideWithValue(repository),
            expenseTreeProvider.overrideWith((ref) => Stream.value(roots)),
            dashboardTodayProvider.overrideWith((ref) => Stream.value(asOf)),
            isOfflineProvider.overrideWith((ref) => false),
            pendingTransactionDraftsProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Jahresbilanz · 2024'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Jahresbilanz · 2024'), findsOneWidget);
      expect(find.text('Jahr vergangen: 50.0 %'), findsOneWidget);
      expect(find.textContaining('700.00 CHF'), findsWidgets);
      expect(find.text('300.00 CHF'), findsWidgets);
      expect(
        find.textContaining('Bis 01.07.2024 · Jahresbudget:'),
        findsOneWidget,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(DashboardScreen)),
      );
      container.read(dashboardSelectedMonthProvider.notifier).moveBy(-13);
      await tester.pumpAndSettle();
      expect(find.text('Jahresbilanz · 2024'), findsOneWidget);

      final card = find.ancestor(
        of: find.text('Jahresbilanz · 2024'),
        matching: find.byType(Card),
      );
      final bars = find.descendant(
        of: card,
        matching: find.byType(DashboardProgressBar),
      );
      final indicators = find.descendant(
        of: card,
        matching: find.byType(LinearProgressIndicator),
      );
      final markers = find.descendant(
        of: bars,
        matching: find.byType(Positioned),
      );
      expect(bars, findsNWidgets(3));
      expect(indicators, findsNWidgets(3));
      expect(markers, findsNWidgets(3));
      final labels = find.descendant(
        of: card,
        matching: find.byType(DashboardPaceLabel),
      );
      expect(labels, findsNWidgets(3));
      expect(find.text('Budget bis heute: 700.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 600.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 100.00 CHF'), findsOneWidget);
      for (var index = 0; index < 3; index++) {
        final label = labels.at(index);
        final labelText = find.descendant(
          of: label,
          matching: find.byType(Text),
        );
        expect(
          tester.getTopRight(labelText).dx,
          closeTo(tester.getTopRight(label).dx, 0.01),
        );
        expect(
          tester.getTopLeft(label).dy,
          greaterThanOrEqualTo(tester.getBottomLeft(bars.at(index)).dy),
        );
      }
      expect(find.textContaining('unter dem Zeitplan'), findsNothing);
      expect(find.textContaining('über dem Zeitplan'), findsNothing);
      final totalMarker = tester.widget<Positioned>(
        find.descendant(of: bars.first, matching: find.byType(Positioned)),
      );
      final totalBar = find.descendant(
        of: bars.first,
        matching: find.byType(LinearProgressIndicator),
      );
      expect(
        totalMarker.left,
        closeTo((tester.getSize(totalBar).width - 3) / 2, 0.01),
      );
      final allCategories = find.descendant(
        of: card,
        matching: find.text('Alle Kategorien'),
      );
      await tester.ensureVisible(allCategories);
      await tester.pumpAndSettle();
      await tester.tap(allCategories);
      await tester.pumpAndSettle();
      expect(find.text('Haushalt'), findsOneWidget);
      expect(find.text('Lebensmittel'), findsOneWidget);
      expect(find.text('Reisen'), findsOneWidget);
      expect(find.text('300.00 CHF / 1400.00 CHF'), findsOneWidget);
      expect(find.text('300.00 CHF / 1200.00 CHF'), findsOneWidget);
      expect(find.text('0.00 CHF / 200.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 700.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 600.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 100.00 CHF'), findsOneWidget);
      expect(find.textContaining('unter dem Zeitplan'), findsNothing);

      await tester.ensureVisible(find.text('Lebensmittel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lebensmittel'));
      await tester.pumpAndSettle();
      expect(find.text('300.00 CHF / 1200.00 CHF'), findsOneWidget);
      expect(find.text('Budget bis heute: 600.00 CHF'), findsOneWidget);
      expect(find.text('January'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsNothing);

      await repository.addTransaction(
        makeTransaction(
          id: 'new',
          expenseNodeId: 'food',
          amountMinor: 5000,
          dateTime: DateTime.utc(2024, 7, 1, 11),
          note: 'New purchase',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('New purchase'), findsOneWidget);
      expect(find.text('350.00 CHF / 1200.00 CHF'), findsOneWidget);
    },
  );

  testWidgets('rolls over to the new year while the overview is open', (
    tester,
  ) async {
    final repository = TransactionRepository(
      'test-user',
      FakeFirebaseFirestore(),
    );
    final today = StreamController<DateTime>();
    addTearDown(today.close);
    await repository.addTransaction(
      makeTransaction(
        id: 'old',
        expenseNodeId: 'food',
        amountMinor: 10000,
        dateTime: DateTime.utc(2024, 12, 31, 12),
      ),
    );
    await repository.addTransaction(
      makeTransaction(
        id: 'new',
        expenseNodeId: 'food',
        amountMinor: 20000,
        dateTime: DateTime.utc(2025, 1, 1, 12),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(repository),
          expenseTreeProvider.overrideWith(
            (ref) => Stream.value([makeExpense(id: 'food')]),
          ),
          dashboardTodayProvider.overrideWith((ref) => today.stream),
          isOfflineProvider.overrideWith((ref) => false),
          pendingTransactionDraftsProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    today.add(DateTime(2024, 12, 31));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Jahresbilanz · 2024'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('100.00 CHF'), findsWidgets);

    today.add(DateTime(2025, 1, 1));
    await tester.pumpAndSettle();
    expect(find.text('Jahresbilanz · 2025'), findsOneWidget);
    expect(find.text('200.00 CHF'), findsWidgets);
    expect(find.text('Jahr vergangen: 0.3 %'), findsOneWidget);
  });

  testWidgets('shows an explicit error if current-month data fails', (
    tester,
  ) async {
    final asOf = DateTime(2024, 7, 1);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(
            TransactionRepository('test-user', FakeFirebaseFirestore()),
          ),
          expenseTreeProvider.overrideWith((ref) => Stream.value([])),
          dashboardTodayProvider.overrideWith((ref) => Stream.value(asOf)),
          dashboardCurrentMonthTransactionsProvider(asOf).overrideWith(
            (ref) => Stream.error(StateError('transaction query failed')),
          ),
          isOfflineProvider.overrideWith((ref) => false),
          pendingTransactionDraftsProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Die Jahresbilanz konnte nicht geladen werden.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Erneut versuchen'), findsOneWidget);
  });
}
