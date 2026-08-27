enum TransactionDraftStatus { pending, saved, discarded }

/// A parsed notification candidate that requires explicit user review.
///
/// The model intentionally contains parsed fields only, never raw notification
/// title or body text.
class TransactionDraft {
  final String id;
  final String sourcePackage;
  final String sourceDedupeKey;
  final DateTime capturedAt;
  final DateTime occurredAt;
  final String merchant;
  final String normalizedMerchant;
  final int amountMinor;
  final String currencyCode;
  final int parserVersion;
  final TransactionDraftStatus status;
  final String? suggestedExpenseNodeId;
  final String? savedTransactionId;
  final DateTime? reviewedAt;

  const TransactionDraft({
    required this.id,
    required this.sourcePackage,
    required this.sourceDedupeKey,
    required this.capturedAt,
    required this.occurredAt,
    required this.merchant,
    required this.normalizedMerchant,
    required this.amountMinor,
    required this.currencyCode,
    required this.parserVersion,
    this.status = TransactionDraftStatus.pending,
    this.suggestedExpenseNodeId,
    this.savedTransactionId,
    this.reviewedAt,
  });

  double get amount => amountMinor / 100;
}
