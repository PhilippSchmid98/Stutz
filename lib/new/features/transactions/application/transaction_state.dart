import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'transaction_service.dart'; // Importiert den Service von unten

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
List<DateTime> availableMonths(Ref ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final uniqueMonths = <DateTime>{};
      final now = DateTime.now();
      uniqueMonths.add(DateTime(now.year, now.month));

      for (var txn in transactions) {
        uniqueMonths.add(DateTime(txn.dateTime.year, txn.dateTime.month));
      }

      return uniqueMonths.toList()..sort((a, b) => a.compareTo(b));
    },
    loading: () => [DateTime(DateTime.now().year, DateTime.now().month)],
    error: (_, __) => [DateTime(DateTime.now().year, DateTime.now().month)],
  );
}
