import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stutz/features/budget/application/selectable_categories_provider.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft_confirmation.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/notification_import/domain/entities/transaction_draft.dart';
import 'package:stutz/features/notification_import/presentation/pending_transaction_drafts_indicator.dart';
import 'package:stutz/features/notification_import/presentation/transaction_draft_review_sheet.dart';

void main() {
  testWidgets('shows batch progress and defers the remaining drafts', (
    tester,
  ) async {
    final result = Completer<DraftReviewSessionResult>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectableCategoriesProvider.overrideWith((ref) async => []),
          merchantCategorySuggestionProvider(
            'coop pronto',
          ).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result.complete(
                  await showTransactionDraftReviewSession(context, [
                    _draft('first', 'Coop Pronto'),
                    _draft('second', 'Migros'),
                  ]),
                );
              },
              child: const Text('Start review'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Start review'));
    await tester.pumpAndSettle();

    expect(find.text('1 von 2'), findsOneWidget);

    await tester.tap(find.text('Später'));
    await tester.pumpAndSettle();

    final reviewResult = await result.future;
    expect(reviewResult.handledDraftIds, isEmpty);
    expect(reviewResult.deferredRemainingDrafts, isTrue);
  });

  testWidgets('advances to the next draft without closing the sheet', (
    tester,
  ) async {
    final mutations = _TrackingDraftMutations();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectableCategoriesProvider.overrideWith(
            (ref) async => const [ExpenseNode(id: 'food', name: 'Essen')],
          ),
          merchantCategorySuggestionProvider(
            'coop pronto',
          ).overrideWith((ref) async => null),
          merchantCategorySuggestionProvider(
            'migros',
          ).overrideWith((ref) async => null),
          transactionDraftMutationsProvider.overrideWith(() => mutations),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: TransactionDraftReviewSheet(
              drafts: [
                _draft('first', 'Coop Pronto', suggestedExpenseNodeId: 'food'),
                _draft('second', 'Migros', suggestedExpenseNodeId: 'food'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    expect(mutations.confirmedDraftIds, ['first']);
    expect(find.text('2 von 2'), findsOneWidget);
    expect(find.text('Migros'), findsNWidgets(2));
  });

  testWidgets('opens draft review only after tapping the indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pendingTransactionDraftsProvider.overrideWith(
            (ref) => Stream.value([_draft('first', 'Coop Pronto')]),
          ),
          selectableCategoriesProvider.overrideWith((ref) async => []),
          merchantCategorySuggestionProvider(
            'coop pronto',
          ).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: const [PendingTransactionDraftsIndicator()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Erfasste Ausgabe prüfen'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('pending-drafts-indicator')));
    await tester.pumpAndSettle();

    expect(find.text('Erfasste Ausgabe prüfen'), findsOneWidget);
  });
}

TransactionDraft _draft(
  String id,
  String merchant, {
  String? suggestedExpenseNodeId,
}) {
  return TransactionDraft(
    id: id,
    sourcePackage: 'com.google.android.apps.walletnfcrel',
    sourceDedupeKey: 'dedupe-$id',
    capturedAt: DateTime(2026, 8, 27, 12),
    occurredAt: DateTime(2026, 8, 27, 11, 59),
    merchant: merchant,
    normalizedMerchant: merchant.toLowerCase(),
    amountMinor: 1245,
    currencyCode: 'CHF',
    parserVersion: 1,
    suggestedExpenseNodeId: suggestedExpenseNodeId,
  );
}

class _TrackingDraftMutations extends TransactionDraftMutations {
  final List<String> confirmedDraftIds = [];

  @override
  Future<void> confirm(
    String draftId,
    TransactionDraftConfirmation confirmation,
  ) async {
    confirmedDraftIds.add(draftId);
  }
}
