// // test/presentation/providers/budget_providers_test.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:stutz/presentation/providers/budget_providers.dart';
// import 'package:stutz/presentation/providers/repository_providers.dart';
// import '../../helpers/fake_repositories.dart';
// import '../../helpers/test_data.dart';

// /// Creates a [ProviderContainer] with fake repositories and keeps the
// /// underlying stream providers alive so they can emit before disposal.
// ProviderContainer _buildContainer({
//   required FakeIncomeRepository incomeRepo,
//   required FakeExpenseNodeRepository expenseRepo,
// }) {
//   final container = ProviderContainer(
//     overrides: [
//       incomeSourceRepositoryProvider.overrideWithValue(incomeRepo),
//       expenseNodeRepositoryProvider.overrideWithValue(expenseRepo),
//     ],
//   );

//   // Keep stream providers alive so they can emit before any auto-dispose timer
//   // fires. Without these listeners, loading-state StreamProviders are disposed
//   // before emitting and throw "Bad state: disposed during loading state".
//   container.listen(incomeListProvider, (_, __) {});
//   container.listen(expenseTreeProvider, (_, __) {});

//   return container;
// }

// void main() {
//   group('budgetHealthProvider', () {
//     test(
//       'returns correct income, expenses, balance and isDeficit=false',
//       () async {
//         final container = _buildContainer(
//           incomeRepo: FakeIncomeRepository([makeIncome(amount: 5000)]),
//           expenseRepo: FakeExpenseNodeRepository([
//             makeExpense(plannedAmount: 3000),
//           ]),
//         );
//         addTearDown(container.dispose);

//         final health = await container.read(budgetHealthProvider.future);
//         expect(health.income, 5000.0);
//         expect(health.expenses, 3000.0);
//         expect(health.balance, 2000.0);
//         expect(health.isDeficit, isFalse);
//       },
//     );

//     test('isDeficit true when expenses exceed income', () async {
//       final container = _buildContainer(
//         incomeRepo: FakeIncomeRepository([makeIncome(amount: 1000)]),
//         expenseRepo: FakeExpenseNodeRepository([
//           makeExpense(plannedAmount: 2000),
//         ]),
//       );
//       addTearDown(container.dispose);

//       final health = await container.read(budgetHealthProvider.future);
//       expect(health.isDeficit, isTrue);
//       expect(health.balance, -1000.0);
//     });

//     test('returns zero balance when income equals expenses', () async {
//       final container = _buildContainer(
//         incomeRepo: FakeIncomeRepository([makeIncome(amount: 2000)]),
//         expenseRepo: FakeExpenseNodeRepository([
//           makeExpense(plannedAmount: 2000),
//         ]),
//       );
//       addTearDown(container.dispose);

//       final health = await container.read(budgetHealthProvider.future);
//       expect(health.balance, 0.0);
//       expect(health.isDeficit, isFalse);
//     });

//     test('returns zero income and expenses for empty repositories', () async {
//       final container = _buildContainer(
//         incomeRepo: FakeIncomeRepository([]),
//         expenseRepo: FakeExpenseNodeRepository([]),
//       );
//       addTearDown(container.dispose);

//       final health = await container.read(budgetHealthProvider.future);
//       expect(health.income, 0.0);
//       expect(health.expenses, 0.0);
//       expect(health.balance, 0.0);
//     });
//   });

//   group('totalMonthlyIncomeProvider', () {
//     test('sums monthly incomes', () async {
//       final container = _buildContainer(
//         incomeRepo: FakeIncomeRepository([
//           makeIncome(id: 'i1', amount: 3000),
//           makeIncome(id: 'i2', amount: 2000),
//         ]),
//         expenseRepo: FakeExpenseNodeRepository([]),
//       );
//       addTearDown(container.dispose);

//       final total = await container.read(totalMonthlyIncomeProvider.future);
//       expect(total, 5000.0);
//     });
//   });

//   group('totalMonthlyExpensesProvider', () {
//     test('sums monthly planned expenses', () async {
//       final container = _buildContainer(
//         incomeRepo: FakeIncomeRepository([]),
//         expenseRepo: FakeExpenseNodeRepository([
//           makeExpense(id: 'e1', plannedAmount: 400),
//           makeExpense(id: 'e2', plannedAmount: 600),
//         ]),
//       );
//       addTearDown(container.dispose);

//       final total = await container.read(totalMonthlyExpensesProvider.future);
//       expect(total, 1000.0);
//     });
//   });
// }
