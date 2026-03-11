import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/data/firestore_repositories.dart';
import 'package:stutz/domain/models/models.dart';

part 'category_transactions_provider.g.dart';

/// Returns all transactions for [nodeIds] within the given [year].
/// If [month] is provided, filters to that specific month; otherwise the whole year.
/// Results are sorted by date descending (newest first).
@riverpod
Future<List<Transaction>> categoryTransactions(
  Ref ref,
  List<String> nodeIds,
  int year,
  int? month,
) async {
  final allTxns = await ref
      .watch(transactionRepositoryProvider)
      .getAllTransactions();

  final nodeIdSet = nodeIds.toSet();

  return allTxns.where((t) {
    if (!nodeIdSet.contains(t.expenseNodeId)) return false;
    if (t.dateTime.year != year) return false;
    if (month != null && t.dateTime.month != month) return false;
    return true;
  }).toList()..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}
