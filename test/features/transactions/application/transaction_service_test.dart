import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';

void main() {
  test(
    'pagination state preserves loaded data while tracking load-more errors',
    () {
      final state = PaginatedTransactionsState(
        groupedDays: const [],
        rawTransactions: const [],
        hasReachedMax: false,
      );

      final loading = state.copyWith(
        isLoadingMore: true,
        clearLoadMoreError: true,
      );
      final failed = loading.copyWith(
        isLoadingMore: false,
        loadMoreError: StateError('network failed'),
      );

      expect(loading.groupedDays, same(state.groupedDays));
      expect(loading.rawTransactions, same(state.rawTransactions));
      expect(loading.isLoadingMore, isTrue);
      expect(loading.loadMoreError, isNull);
      expect(failed.groupedDays, same(state.groupedDays));
      expect(failed.rawTransactions, same(state.rawTransactions));
      expect(failed.isLoadingMore, isFalse);
      expect(failed.loadMoreError, isA<StateError>());
    },
  );
}
