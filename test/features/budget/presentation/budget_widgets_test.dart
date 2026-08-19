import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/core/connectivity/connectivity_provider.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/view_models/budget_summary.dart';
import 'package:stutz/features/budget/presentation/budget_planning_screen.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_expense_node_dialog.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_main_category_dialog.dart';
import 'package:stutz/features/budget/presentation/widgets/budget_overview_card.dart';
import 'package:stutz/features/budget/presentation/widgets/expense_item_row.dart';
import 'package:stutz/features/budget/presentation/widgets/expense_section_card.dart';
import 'package:stutz/features/budget/presentation/widgets/income_section_card.dart';
import 'package:stutz/shared/widgets/section_card.dart';

void main() {
  testWidgets('budget planning renders independent loaded sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOfflineProvider.overrideWith((ref) => false),
          incomeListProvider.overrideWith(
            (ref) => Stream.value([
              const IncomeSource(id: 'income', name: 'Lohn', amount: 5000),
            ]),
          ),
          expenseTreeProvider.overrideWith(
            (ref) => Stream.value([
              const ExpenseNode(id: 'housing', name: 'Wohnen'),
            ]),
          ),
          budgetSummaryProvider.overrideWith(
            (ref) => Future.value(
              const BudgetSummary(
                monthlyIncome: 5000,
                monthlyExpenses: 1200,
                fixedExpenses: 1200,
                variableExpenses: 0,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: BudgetPlanningScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Budget Planung'), findsOneWidget);
    expect(find.text('Lohn'), findsOneWidget);
    expect(find.text('WOHNEN'), findsOneWidget);
    expect(find.text('+ 3800.00 CHF'), findsOneWidget);
    expect(find.text('Neue Hauptkategorie erstellen'), findsOneWidget);
  });

  testWidgets('section card renders totals and invokes header action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SectionCard(
            title: 'EINNAHMEN',
            totalMonthly: 5000,
            totalYearly: 0,
            icon: Icons.trending_up,
            iconColor: Colors.green,
            backgroundColor: Colors.green.shade50,
            onHeaderTap: () => tapped = true,
            children: const [Text('Content')],
          ),
        ),
      ),
    );

    expect(find.text('EINNAHMEN'), findsOneWidget);
    expect(find.text('5000.00 / Monat'), findsOneWidget);
    expect(find.text('Content'), findsOneWidget);

    await tester.tap(find.text('EINNAHMEN'));
    expect(tapped, isTrue);
  });

  testWidgets('income section renders grouped income sources', (tester) async {
    const incomes = [
      IncomeSource(
        id: 'main',
        name: 'Lohn',
        amount: 5000,
        interval: PaymentInterval.monthly,
        group: IncomeGroup.main,
      ),
      IncomeSource(
        id: 'extra',
        name: 'Nebenjob',
        amount: 600,
        interval: PaymentInterval.yearly,
        group: IncomeGroup.additional,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: IncomeSectionCard(
            incomes: incomes,
            monthlyTotal: 5050,
            yearlyTotal: 600,
          ),
        ),
      ),
    );

    expect(find.text('HAUPTEINNAHMEN'), findsOneWidget);
    expect(find.text('NEBENEINNAHMEN'), findsOneWidget);
    expect(find.text('Lohn'), findsOneWidget);
    expect(find.text('Nebenjob'), findsOneWidget);
  });

  testWidgets('expense section renders a group and nested leaf', (
    tester,
  ) async {
    const root = ExpenseNode(
      id: 'housing',
      name: 'Wohnen',
      children: [
        ExpenseNode(
          id: 'rent',
          parentId: 'housing',
          name: 'Miete',
          plannedAmount: 1200,
          interval: PaymentInterval.monthly,
          type: ExpenseType.fixed,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpenseSectionCard(
            rootNode: root,
            monthlyTotal: 1200,
            yearlyTotal: 0,
          ),
        ),
      ),
    );

    expect(find.text('WOHNEN'), findsOneWidget);
    expect(find.text('Miete'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open), findsOneWidget);
    expect(find.text('+ Eintrag hinzufügen'), findsOneWidget);
  });

  testWidgets('leaf rows show amounts while empty groups show child action', (
    tester,
  ) async {
    const leaf = ExpenseNode(
      id: 'leaf',
      name: 'Versicherung',
      plannedAmount: 120,
      interval: PaymentInterval.yearly,
      type: ExpenseType.fixed,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExpenseItemRow(node: leaf, depth: 0)),
      ),
    );
    expect(find.text('120.00'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);

    const emptyGroup = ExpenseNode(id: 'group', name: 'Leer');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExpenseItemRow(node: emptyGroup, depth: 0)),
      ),
    );
    expect(find.text('Leer'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
  });

  testWidgets('adding a child does not also open the edit dialog', (
    tester,
  ) async {
    const emptyGroup = ExpenseNode(id: 'group', name: 'Leer');

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ExpenseItemRow(node: emptyGroup, depth: 0)),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AddExpenseNodeDialog), findsOneWidget);
    final dialog = tester.widget<AddExpenseNodeDialog>(
      find.byType(AddExpenseNodeDialog),
    );
    expect(dialog.parentId, 'group');
    expect(dialog.existingNode, isNull);
  });

  testWidgets('budget overview displays balance and expense split', (
    tester,
  ) async {
    const summary = BudgetSummary(
      monthlyIncome: 5000,
      monthlyExpenses: 2500,
      fixedExpenses: 1800,
      variableExpenses: 700,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BudgetOverviewCard(summary: summary)),
      ),
    );

    expect(find.text('+ 2500.00 CHF'), findsOneWidget);
    expect(find.text('Verfügbarer Überschuss'), findsOneWidget);
    expect(find.text('1800.00'), findsOneWidget);
    expect(find.text('700.00'), findsOneWidget);
  });

  testWidgets('main category dialog validates a required name', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AddMainCategoryDialog())),
      ),
    );

    await tester.tap(find.text('Erstellen'));
    await tester.pump();

    expect(find.text('Pflichtfeld'), findsOneWidget);
  });

  testWidgets('expense dialog validates a required name', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AddExpenseNodeDialog(parentId: 'root')),
        ),
      ),
    );

    await tester.tap(find.text('Speichern'));
    await tester.pump();

    expect(find.text('Pflichtfeld'), findsNWidgets(2));
  });

  testWidgets('group deletion warns before submitting the delete attempt', (
    tester,
  ) async {
    final mutations = _TrackingBudgetMutations();
    const group = ExpenseNode(
      id: 'group',
      name: 'Wohnen',
      children: [ExpenseNode(id: 'child', name: 'Miete')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [budgetMutationsProvider.overrideWith(() => mutations)],
        child: const MaterialApp(
          home: Scaffold(body: AddExpenseNodeDialog(existingNode: group)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();

    expect(find.text('ACHTUNG: Gruppe mit Inhalt löschen?'), findsOneWidget);

    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();

    expect(mutations._deletedId, 'group');
  });
}

class _TrackingBudgetMutations extends BudgetMutations {
  String? _deletedId;

  @override
  Future<void> deleteExpenseNode(String id) async {
    _deletedId = id;
    state = const AsyncData(null);
  }
}
