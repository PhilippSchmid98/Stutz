import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/application/budget_mutations.dart';
import 'package:stutz/features/budget/data/expense_node_repository.dart';
import 'package:stutz/features/budget/data/income_source_repository.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

void main() {
  test('add income reports success after awaiting the repository', () async {
    final repository = _FakeIncomeSourceRepository();
    final container = ProviderContainer(
      overrides: [
        incomeSourceRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    final source = IncomeSource(id: 'income-1', name: 'Salary', amount: 3000);
    await container
        .read(budgetMutationsProvider.notifier)
        .addIncomeSource(source);

    expect(repository.added, [source]);
    expect(
      container.read(budgetMutationsProvider),
      const AsyncData<void>(null),
    );
  });

  test('failed expense writes report AsyncError and rethrow', () async {
    final repository = _FakeExpenseNodeRepository()
      ..error = StateError('offline');
    final container = ProviderContainer(
      overrides: [
        expenseNodeRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    final node = ExpenseNode(
      id: 'expense-1',
      name: 'Food',
      plannedAmount: 300,
      interval: PaymentInterval.monthly,
      type: ExpenseType.variable,
    );

    await expectLater(
      container.read(budgetMutationsProvider.notifier).addExpenseNode(node),
      throwsA(isA<StateError>()),
    );

    final state = container.read(budgetMutationsProvider);
    expect(state, isA<AsyncError<void>>());
    expect(state.error, isA<StateError>());
  });
}

class _FakeIncomeSourceRepository implements IncomeSourceRepository {
  @override
  String get userId => 'test-user';

  final added = <IncomeSource>[];
  Object? error;

  @override
  Future<void> addIncomeSource(IncomeSource source) async {
    if (error != null) throw error!;
    added.add(source);
  }

  @override
  Future<void> updateIncomeSource(IncomeSource source) async {}

  @override
  Future<void> deleteIncomeSource(String id) async {}

  @override
  Future<List<IncomeSource>> getAllIncomeSources() async => [];

  @override
  Stream<List<IncomeSource>> watchAllIncomeSources() => const Stream.empty();
}

class _FakeExpenseNodeRepository implements ExpenseNodeRepository {
  @override
  String get userId => 'test-user';

  Object? error;

  @override
  Future<void> addExpenseNode(ExpenseNode node) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> updateExpenseNode(ExpenseNode node) async {}

  @override
  Future<void> deleteExpenseNode(String id) async {}

  @override
  Future<List<ExpenseNode>> getAllExpenseNodes() async => [];

  @override
  Stream<List<ExpenseNode>> watchAllExpenseNodes() => const Stream.empty();

  @override
  Future<void> updateNodeOrder(List<ExpenseNode> sortedNodes) async {}
}
