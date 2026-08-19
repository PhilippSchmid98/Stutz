import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stutz/features/budget/application/selectable_categories_provider.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';
import 'package:stutz/features/transactions/domain/view_models/daily_transactions.dart';
import 'package:stutz/features/transactions/domain/view_models/transaction_with_category.dart';
import 'package:stutz/features/transactions/presentation/add_transaction_dialog.dart';
import 'package:stutz/features/transactions/presentation/widgets/daily_transaction_group.dart';
import 'package:stutz/features/transactions/presentation/widgets/month_selector.dart';
import 'package:stutz/features/transactions/presentation/widgets/transaction_item.dart';

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
    expect(find.text('-42.50'), findsOneWidget);
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
    expect(find.text('-42.50'), findsNWidgets(2));
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
}
