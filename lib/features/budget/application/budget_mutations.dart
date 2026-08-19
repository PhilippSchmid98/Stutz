import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/data/expense_node_repository.dart';
import 'package:stutz/features/budget/data/income_source_repository.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';

part 'budget_mutations.g.dart';

@riverpod
class BudgetMutations extends _$BudgetMutations {
  @override
  FutureOr<void> build() {}

  Future<void> addExpenseNode(ExpenseNode node) {
    return _run(() async {
      node.validateForWrite();
      await ref.read(expenseNodeRepositoryProvider).addExpenseNode(node);
    });
  }

  Future<void> updateExpenseNode(ExpenseNode node) {
    return _run(() async {
      node.validateForWrite();
      await ref.read(expenseNodeRepositoryProvider).updateExpenseNode(node);
    });
  }

  Future<void> deleteExpenseNode(String id) {
    return _run(
      () => ref.read(expenseNodeRepositoryProvider).deleteExpenseNode(id),
    );
  }

  Future<void> addIncomeSource(IncomeSource source) {
    return _run(
      () => ref.read(incomeSourceRepositoryProvider).addIncomeSource(source),
    );
  }

  Future<void> updateIncomeSource(IncomeSource source) {
    return _run(
      () => ref.read(incomeSourceRepositoryProvider).updateIncomeSource(source),
    );
  }

  Future<void> deleteIncomeSource(String id) {
    return _run(
      () => ref.read(incomeSourceRepositoryProvider).deleteIncomeSource(id),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
