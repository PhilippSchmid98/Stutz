import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';

abstract interface class TransactionDraftStore {
  Future<void> upsertCapturedDraft(TransactionDraft draft);
}
