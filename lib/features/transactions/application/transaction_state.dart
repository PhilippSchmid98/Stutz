import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_month.dart';

part 'transaction_state.g.dart';

@riverpod
class CurrentVisibleMonth extends _$CurrentVisibleMonth {
  @override
  DateTime build() {
    return TransactionMonth.current();
  }

  void set(DateTime date) {
    state = date;
  }
}

@riverpod
Future<List<DateTime>> availableMonths(Ref ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final indexedMonths = await repo.getIndexedTransactionMonths();
  final currentMonth = repo.currentTransactionMonth;

  if (indexedMonths != null) {
    final visibleMonths = indexedMonths
        .where((month) => !month.isAfter(currentMonth))
        .toList();
    return visibleMonths.isEmpty ? [currentMonth] : visibleMonths;
  }

  final oldestTxn = await repo.getOldestTransaction();

  final List<DateTime> months = [];

  // Wenn keine Transaktionen existieren, nur den aktuellen Monat anzeigen
  if (oldestTxn == null) {
    return [currentMonth];
  }

  var runner = TransactionMonth.fromDateTime(oldestTxn.dateTime);
  final end = DateTime(currentMonth.year, currentMonth.month + 1);

  while (runner.isBefore(end)) {
    months.add(DateTime(runner.year, runner.month));
    runner = DateTime(runner.year, runner.month + 1);
  }

  // Aufsteigend sortieren (Januar -> Dezember)
  return months..sort((a, b) => a.compareTo(b));
}
