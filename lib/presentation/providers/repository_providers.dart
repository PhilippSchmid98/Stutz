// Datei: lib/presentation/providers/repository_providers.dart
//
// Centralized Riverpod providers for all domain repository interfaces.
// This is the single file that bridges the data layer (Firestore
// implementations) with the presentation layer. All other presentation files
// import from here — never from data/ directly.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/repositories/firestore_expense_repository.dart';
import 'package:stutz/presentation/providers/auth_provider.dart';
//import 'package:stutz/data/repositories/firestore_income_repository.dart';
import 'package:stutz/data/repositories/firestore_transaction_repository.dart';
import 'package:stutz/domain/repositories/expense_repository.dart';
//import 'package:stutz/domain/repositories/income_repository.dart';
import 'package:stutz/domain/repositories/transaction_repository.dart';

part 'repository_providers.g.dart';

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
}

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (TransactionRepo)');
  return FirestoreTransactionRepository(uid);
}

@riverpod
ExpenseNodeRepository expenseNodeRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) throw Exception('Not logged in (ExpenseRepo)');
  return FirestoreExpenseNodeRepository(uid);
}

// @riverpod
// IncomeSourceRepository incomeSourceRepository(Ref ref) {
//   final uid = ref.watch(currentUserIdProvider);
//   if (uid == null) throw Exception('Not logged in (IncomeRepo)');
//   return FirestoreIncomeRepository(uid);
// }
