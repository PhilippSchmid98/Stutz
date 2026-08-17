import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transaction_repository.dart';

part 'transaction_state.g.dart';

@riverpod
class CurrentVisibleMonth extends _$CurrentVisibleMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void set(DateTime date) {
    state = date;
  }
}

@riverpod
Future<List<DateTime>> availableMonths(Ref ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final oldestTxn = await repo.getOldestTransaction();

  final List<DateTime> months = [];
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);

  // Wenn keine Transaktionen existieren, nur den aktuellen Monat anzeigen
  if (oldestTxn == null) {
    return [currentMonth];
  }

  var runner = DateTime(oldestTxn.dateTime.year, oldestTxn.dateTime.month);
  final end = DateTime(
    now.year,
    now.month + 1,
  ); // Bis zum nächsten Monat laufen lassen

  while (runner.isBefore(end)) {
    months.add(DateTime(runner.year, runner.month));
    runner = DateTime(runner.year, runner.month + 1);
  }

  // Aufsteigend sortieren (Januar -> Dezember)
  return months..sort((a, b) => a.compareTo(b));
}
