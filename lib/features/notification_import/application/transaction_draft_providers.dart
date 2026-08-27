import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_repository.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft_confirmation.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';

part 'transaction_draft_providers.g.dart';

@riverpod
Stream<List<TransactionDraft>> pendingTransactionDrafts(Ref ref) {
  return ref.watch(transactionDraftRepositoryProvider).watchPendingDrafts();
}

@riverpod
Future<String?> merchantCategorySuggestion(Ref ref, String normalizedMerchant) {
  return ref
      .watch(transactionDraftRepositoryProvider)
      .getSuggestedExpenseNodeId(normalizedMerchant);
}

@riverpod
class TransactionDraftMutations extends _$TransactionDraftMutations {
  @override
  FutureOr<void> build() {}

  Future<void> confirm(
    String draftId,
    TransactionDraftConfirmation confirmation,
  ) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(transactionDraftRepositoryProvider)
          .confirmDraft(draftId, confirmation);
      _refreshData();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> discard(String draftId) async {
    state = const AsyncLoading();
    try {
      await ref.read(transactionDraftRepositoryProvider).discardDraft(draftId);
      ref.invalidate(pendingTransactionDraftsProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _refreshData() {
    ref.invalidate(pendingTransactionDraftsProvider);
    ref.invalidate(paginatedTransactionListProvider);
    ref.invalidate(availableMonthsProvider);
  }
}
