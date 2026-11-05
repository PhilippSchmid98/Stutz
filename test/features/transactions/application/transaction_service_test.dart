import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';

void main() {
  test(
    'pagination state preserves loaded data while tracking older-page errors',
    () {
      final state = PaginatedTransactionsState(
        groupedDays: const [],
        rawTransactions: const [],
        hasReachedOldest: false,
      );

      final loading = state.copyWith(
        isLoadingOlder: true,
        clearLoadOlderError: true,
      );
      final failed = loading.copyWith(
        isLoadingOlder: false,
        loadOlderError: StateError('network failed'),
      );

      expect(loading.groupedDays, same(state.groupedDays));
      expect(loading.rawTransactions, same(state.rawTransactions));
      expect(loading.isLoadingOlder, isTrue);
      expect(loading.loadOlderError, isNull);
      expect(failed.groupedDays, same(state.groupedDays));
      expect(failed.rawTransactions, same(state.rawTransactions));
      expect(failed.isLoadingOlder, isFalse);
      expect(failed.loadOlderError, isA<StateError>());
    },
  );
}
