import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stutz/core/connectivity/connectivity_provider.dart';
import 'package:stutz/features/budget/application/selectable_categories_provider.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/view_models/daily_transactions.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';
import 'package:stutz/features/transactions/presentation/add_transaction_dialog.dart';
import 'package:stutz/features/transactions/presentation/transaction_screen.dart';
import 'package:stutz/features/transactions/presentation/widgets/daily_transaction_group.dart';
import 'package:stutz/features/transactions/presentation/widgets/month_selector.dart';
import 'package:stutz/features/transactions/presentation/widgets/transaction_item.dart';
import 'package:stutz/features/transactions/presentation/widgets/category_picker_sheet.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de_DE');
  });

  final transaction = AppTransaction(
    id: 'transaction',
    expenseNodeId: 'category',
    amount: 42.5,
    dateTime: DateTime(2025, 6, 15, 18, 30),
    note: 'Abendessen',
  );
  final item = TransactionWithCategory(
    transaction: transaction,
    categoryName: 'Restaurant',
  );

  testWidgets('transaction item renders category, note, and amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: TransactionItem(item: item)),
        ),
      ),
    );

    expect(find.text('Restaurant'), findsOneWidget);
    expect(find.text('Abendessen'), findsOneWidget);
    expect(find.text('-42.50 CHF'), findsOneWidget);
  });

  testWidgets('daily transaction group renders localized date and total', (
    tester,
  ) async {
    final group = DailyTransactions(
      date: DateTime(2025, 6, 15),
      totalAmount: 42.5,
      transactions: [item],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: DailyTransactionGroup(group: group)),
        ),
      ),
    );

    expect(find.text('15.06'), findsOneWidget);
    expect(find.text('Sonntag'), findsOneWidget);
    expect(find.text('-42.50 CHF'), findsNWidgets(2));
  });

  testWidgets('month selector exposes loaded months and selection callback', (
    tester,
  ) async {
    DateTime? selectedMonth;
    final months = [DateTime(2025, 1), DateTime(2025, 2)];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availableMonthsProvider.overrideWith((ref) async => months),
          currentVisibleMonthProvider.overrideWithValue(months.first),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CleanMonthSelector(
              onMonthSelected: (month) => selectedMonth = month,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jan 25'), findsOneWidget);
    expect(find.text('Feb 25'), findsOneWidget);

    await tester.tap(find.text('Feb 25'));
    expect(selectedMonth, months.last);
  });

  testWidgets('category picker filters and returns a selected category', (
    tester,
  ) async {
    const categories = [
      ExpenseNode(id: 'food', name: 'Lebensmittel'),
      ExpenseNode(id: 'transport', name: 'ÖV'),
    ];
    ExpenseNode? selectedCategory;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              selectedCategory = await showAppBottomSheet<ExpenseNode>(
                context: tester.element(find.byType(ElevatedButton)),
                builder: (_) => const CategoryPickerSheet(
                  categories: AsyncData(categories),
                  selectedNodeId: null,
                ),
              );
            },
            child: const Text('Kategorie öffnen'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kategorie öffnen'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'lebens');
    await tester.pumpAndSettle();
    expect(find.text('Lebensmittel'), findsOneWidget);
    expect(find.text('ÖV'), findsNothing);

    await tester.tap(find.text('Lebensmittel'));
    await tester.pumpAndSettle();
    expect(selectedCategory?.id, 'food');
  });

  testWidgets('transaction dialog requires a category before saving', (
    tester,
  ) async {
    final category = ExpenseNode(
      id: 'category',
      name: 'Lebensmittel',
      plannedAmount: 100,
      interval: PaymentInterval.monthly,
      type: ExpenseType.variable,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectableCategoriesProvider.overrideWith((ref) async => [category]),
        ],
        child: const MaterialApp(home: Scaffold(body: AddTransactionDialog())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '25');
    await tester.tap(find.text('Speichern'));
    await tester.pump();

    expect(find.text('Bitte Kategorie wählen'), findsOneWidget);
  });

  testWidgets('transaction dialog renders dates without a time', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectableCategoriesProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          home: Scaffold(body: AddTransactionDialog(existingItem: item)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('15.06.2025'), findsOneWidget);
    expect(find.textContaining('18:30'), findsNothing);
  });

  testWidgets('transaction dialog shows category loading errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectableCategoriesProvider.overrideWith((ref) async {
            throw StateError('categories unavailable');
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: AddTransactionDialog())),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Kategorien konnten nicht geladen werden.'),
      findsOneWidget,
    );
  });

  testWidgets('transaction screen shows its initial loading state', (
    tester,
  ) async {
    final pending = Completer<PaginatedTransactionsState>();

    await _pumpTransactionScreen(
      tester,
      paginatedMode: _TransactionScreenMode.loading,
      pending: pending,
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Keine Ausgaben.'), findsNothing);

    pending.complete(_emptyTransactionState());
    await tester.pump();
  });

  testWidgets('transaction screen hides raw initial errors', (tester) async {
    await _pumpTransactionScreen(
      tester,
      paginatedMode: _TransactionScreenMode.error,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Transaktionen konnten nicht geladen werden.'),
      findsOneWidget,
    );
    expect(find.text('private transaction detail'), findsNothing);
  });

  testWidgets('transaction screen renders the empty state', (tester) async {
    await _pumpTransactionScreen(
      tester,
      paginatedMode: _TransactionScreenMode.empty,
    );
    await tester.pumpAndSettle();

    expect(find.text('Keine Ausgaben.'), findsOneWidget);
  });

  testWidgets(
    'transaction screen does not show a snackbar for an empty month',
    (tester) async {
      await _pumpTransactionScreen(
        tester,
        paginatedMode: _TransactionScreenMode.empty,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Juni 25'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'transaction screen exposes a retry action for load-more errors',
    (tester) async {
      final fake = _FakePaginatedTransactionList(
        _TransactionScreenMode.loadMoreError,
      );

      await _pumpTransactionScreen(tester, paginatedNotifier: fake);
      await tester.pumpAndSettle();

      expect(
        find.text('Weitere Transaktionen konnten nicht geladen werden.'),
        findsOneWidget,
      );
      expect(find.text('Erneut versuchen'), findsOneWidget);

      final callsBeforeRetry = fake._loadNextPageCalls;
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pump();

      expect(fake._loadNextPageCalls, callsBeforeRetry + 1);
    },
  );
}

Future<void> _pumpTransactionScreen(
  WidgetTester tester, {
  _TransactionScreenMode paginatedMode = _TransactionScreenMode.empty,
  Completer<PaginatedTransactionsState>? pending,
  _FakePaginatedTransactionList? paginatedNotifier,
}) {
  final month = DateTime(2025, 6);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        isOfflineProvider.overrideWithValue(false),
        availableMonthsProvider.overrideWith((ref) async => [month]),
        currentVisibleMonthProvider.overrideWith(
          () => _FakeCurrentVisibleMonth(month),
        ),
        paginatedTransactionListProvider.overrideWith(
          () =>
              paginatedNotifier ??
              _FakePaginatedTransactionList(paginatedMode, pending),
        ),
      ],
      child: const MaterialApp(home: TransactionScreen()),
    ),
  );
}

enum _TransactionScreenMode { loading, error, empty, loadMoreError }

class _FakeCurrentVisibleMonth extends CurrentVisibleMonth {
  final DateTime initialMonth;

  _FakeCurrentVisibleMonth(this.initialMonth);

  @override
  DateTime build() => initialMonth;
}

class _FakePaginatedTransactionList extends PaginatedTransactionList {
  final _TransactionScreenMode _mode;
  final Completer<PaginatedTransactionsState>? _pending;
  int _loadNextPageCalls = 0;

  _FakePaginatedTransactionList(this._mode, [this._pending]);

  @override
  Future<PaginatedTransactionsState> build() async {
    switch (_mode) {
      case _TransactionScreenMode.loading:
        return _pending!.future;
      case _TransactionScreenMode.error:
        throw StateError('private transaction detail');
      case _TransactionScreenMode.empty:
        return _emptyTransactionState();
      case _TransactionScreenMode.loadMoreError:
        return _loadMoreErrorState();
    }
  }

  @override
  Future<void> loadNextPage() async {
    _loadNextPageCalls++;
  }

  @override
  Future<bool> ensureMonthLoaded(DateTime month) async => false;
}

PaginatedTransactionsState _emptyTransactionState() {
  return PaginatedTransactionsState(
    groupedDays: const [],
    rawTransactions: const [],
    hasReachedMax: true,
  );
}

PaginatedTransactionsState _loadMoreErrorState() {
  return PaginatedTransactionsState(
    groupedDays: [
      DailyTransactions(
        date: DateTime(2025, 6, 15),
        totalAmount: 0,
        transactions: const [],
      ),
    ],
    rawTransactions: const [],
    hasReachedMax: false,
    loadMoreError: StateError('load more unavailable'),
  );
}
