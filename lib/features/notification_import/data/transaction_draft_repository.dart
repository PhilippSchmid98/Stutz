import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/features/notification_import/data/transaction_draft_mapper.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft_confirmation.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/notification_import/domain/repositories/transaction_draft_store.dart';
import 'package:stutz/features/notification_import/domain/services/merchant_category_rule_id.dart';
import 'package:stutz/features/transactions/data/transaction_mapper.dart';
import 'package:stutz/features/transactions/data/transaction_month.dart';
import 'package:stutz/features/transactions/domain/entities/app_transaction.dart';

part 'transaction_draft_repository.g.dart';

class TransactionDraftRepository implements TransactionDraftStore {
  final String userId;
  final FirebaseFirestore _firestore;

  TransactionDraftRepository(this.userId, this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('users')
      .doc(userId)
      .collection('transactionDrafts');

  Stream<List<TransactionDraft>> watchPendingDrafts() {
    return _collection
        .where('status', isEqualTo: TransactionDraftStatus.pending.name)
        .snapshots()
        .map((snapshot) {
          final drafts = snapshot.docs
              .map(TransactionDraftMapper.fromDocument)
              .toList();
          drafts.sort(
            (left, right) => left.occurredAt.compareTo(right.occurredAt),
          );
          return drafts;
        });
  }

  Future<String?> getSuggestedExpenseNodeId(String normalizedMerchant) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('merchantCategoryRules')
        .doc(merchantCategoryRuleId(normalizedMerchant))
        .get();
    final categoryId = snapshot.data()?['categoryId'];
    return categoryId is String && categoryId.isNotEmpty ? categoryId : null;
  }

  Future<void> discardDraft(String draftId) async {
    await _firestore.runTransaction((transaction) async {
      final reference = _collection.doc(draftId);
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw StateError('Transaction draft $draftId does not exist');
      }

      final draft = TransactionDraftMapper.fromDocument(snapshot);
      if (draft.status != TransactionDraftStatus.pending) return;

      transaction.update(reference, {
        'status': TransactionDraftStatus.discarded.name,
        'reviewedAt': Timestamp.now(),
      });
    });
  }

  Future<String> confirmDraft(
    String draftId,
    TransactionDraftConfirmation confirmation,
  ) async {
    return _firestore.runTransaction((transaction) async {
      final draftReference = _collection.doc(draftId);
      final snapshot = await transaction.get(draftReference);
      if (!snapshot.exists) {
        throw StateError('Transaction draft $draftId does not exist');
      }

      final draft = TransactionDraftMapper.fromDocument(snapshot);
      if (draft.status == TransactionDraftStatus.saved) {
        final savedTransactionId = draft.savedTransactionId;
        if (savedTransactionId == null) {
          throw StateError(
            'Saved transaction draft $draftId has no transaction ID',
          );
        }
        return savedTransactionId;
      }
      if (draft.status == TransactionDraftStatus.discarded) {
        throw StateError('Transaction draft $draftId was discarded');
      }

      final transactionId = 'import_$draftId';
      final dateOnly = DateTime(
        confirmation.dateTime.year,
        confirmation.dateTime.month,
        confirmation.dateTime.day,
      );
      final appTransaction = AppTransaction(
        id: transactionId,
        expenseNodeId: confirmation.expenseNodeId,
        amount: confirmation.amountMinor / 100,
        dateTime: dateOnly,
        note: confirmation.note?.trim().isEmpty ?? true
            ? draft.merchant
            : confirmation.note!.trim(),
      );
      final transactionReference = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId);
      final month = TransactionMonth.fromDateTime(appTransaction.dateTime);
      final monthReference = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactionMonths')
          .doc(TransactionMonth.key(month));
      final ruleReference = _firestore
          .collection('users')
          .doc(userId)
          .collection('merchantCategoryRules')
          .doc(merchantCategoryRuleId(draft.normalizedMerchant));

      transaction.set(
        transactionReference,
        TransactionMapper.toDocument(appTransaction),
      );
      transaction.set(monthReference, {
        'monthKey': monthReference.id,
        'year': month.year,
        'month': month.month,
        'transactionCount': FieldValue.increment(1),
        'categoryTotals': {
          appTransaction.expenseNodeId: FieldValue.increment(
            appTransaction.amount,
          ),
        },
      }, SetOptions(merge: true));
      transaction.update(draftReference, {
        'status': TransactionDraftStatus.saved.name,
        'savedTransactionId': transactionId,
        'suggestedExpenseNodeId': confirmation.expenseNodeId,
        'reviewedAt': Timestamp.now(),
      });
      transaction.set(ruleReference, {
        'normalizedMerchant': draft.normalizedMerchant,
        'categoryId': confirmation.expenseNodeId,
        'confirmationCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      return transactionId;
    });
  }

  /// Writes a newly captured candidate once without changing a reviewed draft.
  @override
  Future<void> upsertCapturedDraft(TransactionDraft draft) async {
    if (draft.status != TransactionDraftStatus.pending) {
      throw ArgumentError.value(
        draft.status,
        'draft.status',
        'Captured drafts must be pending',
      );
    }

    await _firestore.runTransaction((transaction) async {
      final reference = _collection.doc(draft.id);
      final existing = await transaction.get(reference);
      if (existing.exists) return;

      transaction.set(reference, TransactionDraftMapper.toDocument(draft));
    });
  }
}

@riverpod
TransactionDraftRepository transactionDraftRepository(Ref ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    throw Exception('Not logged in (TransactionDraftRepository)');
  }
  return TransactionDraftRepository(uid, FirebaseFirestore.instance);
}
