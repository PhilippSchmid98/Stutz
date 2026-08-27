class TransactionDraftConfirmation {
  final int amountMinor;
  final DateTime dateTime;
  final String expenseNodeId;
  final String? note;

  const TransactionDraftConfirmation({
    required this.amountMinor,
    required this.dateTime,
    required this.expenseNodeId,
    this.note,
  }) : assert(amountMinor > 0),
       assert(expenseNodeId != '');
}
