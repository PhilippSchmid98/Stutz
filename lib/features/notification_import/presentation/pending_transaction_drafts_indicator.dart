import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/notification_import/presentation/transaction_draft_review_sheet.dart';

class PendingTransactionDraftsIndicator extends ConsumerWidget {
  const PendingTransactionDraftsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(pendingTransactionDraftsProvider).asData?.value;
    final count = drafts?.length ?? 0;
    final colorScheme = Theme.of(context).colorScheme;
    final canReview = drafts?.isNotEmpty ?? false;

    return Semantics(
      button: canReview,
      label: '$count erfasste Ausgaben',
      child: Tooltip(
        message: canReview
            ? 'Erfasste Ausgaben prüfen'
            : 'Keine erfassten Ausgaben',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Material(
              color: colorScheme.primary,
              shape: const StadiumBorder(),
              child: InkWell(
                onTap: canReview
                    ? () => showTransactionDraftReviewSession(context, drafts!)
                    : null,
                customBorder: const StadiumBorder(),
                child: SizedBox(
                  key: const ValueKey('pending-drafts-indicator'),
                  width: count < 10 ? 28 : null,
                  height: 28,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Center(
                      child: Text(
                        '$count',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
