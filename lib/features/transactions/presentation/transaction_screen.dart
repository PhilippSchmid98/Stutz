import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import 'package:stutz/features/transactions/presentation/add_transaction_dialog.dart';
import 'package:stutz/features/transactions/presentation/widgets/daily_transaction_group.dart';
import 'package:stutz/features/transactions/presentation/widgets/month_selector.dart';
import 'package:stutz/features/notification_import/application/transaction_draft_providers.dart';
import 'package:stutz/features/notification_import/application/notification_capture_providers.dart';
import 'package:stutz/features/notification_import/presentation/transaction_draft_review_sheet.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';
import 'package:stutz/shared/widgets/dialog_helpers.dart';

class _ScrollAnchor {
  final DateTime date;
  final double alignment;

  const _ScrollAnchor({required this.date, required this.alignment});
}

class TransactionScreen extends HookConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemScrollController = useMemoized(ItemScrollController.new);
    final itemPositionsListener = useMemoized(ItemPositionsListener.create);
    // Mutable flag that does not trigger a rebuild – avoids circular updates
    // when _scrollToMonth drives the list programmatically.
    final isProgrammaticScroll = useRef(false);
    final isUserScroll = useRef(false);
    final newerPageRequestedDuringScroll = useRef(false);
    final olderPageRequestedDuringScroll = useRef(false);

    final paginatedStateAsync = ref.watch(paginatedTransactionListProvider);

    _ScrollAnchor? captureScrollAnchor() {
      final state = ref.read(paginatedTransactionListProvider).value;
      if (state == null) return null;

      final visibleItems =
          itemPositionsListener.itemPositions.value
              .where(
                (position) =>
                    position.index < state.groupedDays.length &&
                    position.itemLeadingEdge < 1 &&
                    position.itemTrailingEdge > 0,
              )
              .toList()
            ..sort((left, right) => left.index.compareTo(right.index));
      if (visibleItems.isEmpty) return null;

      final anchorPosition = visibleItems.firstWhere(
        (position) => position.itemLeadingEdge >= 0,
        orElse: () => visibleItems.first,
      );
      return _ScrollAnchor(
        date: state.groupedDays[anchorPosition.index].date,
        alignment: anchorPosition.itemLeadingEdge.clamp(0.0, 1.0),
      );
    }

    Future<void> loadNewerPage() async {
      final anchor = captureScrollAnchor();
      await ref.read(paginatedTransactionListProvider.notifier).loadNewerPage();
      if (anchor == null || !context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        final groups = ref
            .read(paginatedTransactionListProvider)
            .value
            ?.groupedDays;
        if (groups == null) return;

        final anchorIndex = groups.indexWhere(
          (group) => group.date == anchor.date,
        );
        if (anchorIndex == -1) return;

        isProgrammaticScroll.value = true;
        try {
          itemScrollController.jumpTo(
            index: anchorIndex,
            alignment: anchor.alignment,
          );
        } finally {
          isProgrammaticScroll.value = false;
        }
      });
    }

    useEffect(() {
      void onListScroll() {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isEmpty) return;

        final maxIndex = positions
            .map((e) => e.index)
            .reduce((a, b) => a > b ? a : b);
        final minIndex = positions
            .map((e) => e.index)
            .reduce((a, b) => a < b ? a : b);
        final currentState = ref.read(paginatedTransactionListProvider).value;
        final totalItems = currentState?.groupedDays.length ?? 0;

        if (isUserScroll.value &&
            !newerPageRequestedDuringScroll.value &&
            currentState != null &&
            !currentState.isLoadingNewer &&
            !currentState.hasReachedNewest &&
            totalItems > 0 &&
            minIndex <= 1) {
          newerPageRequestedDuringScroll.value = true;
          loadNewerPage();
        }

        if (isUserScroll.value &&
            !olderPageRequestedDuringScroll.value &&
            currentState != null &&
            !currentState.isLoadingOlder &&
            !currentState.hasReachedOldest &&
            totalItems > 0 &&
            maxIndex >= totalItems - 2) {
          olderPageRequestedDuringScroll.value = true;
          ref.read(paginatedTransactionListProvider.notifier).loadOlderPage();
        }

        if (isProgrammaticScroll.value) return;
        final visibleItems = positions
            .where((pos) => pos.itemLeadingEdge < 1 && pos.itemTrailingEdge > 0)
            .toList();
        if (visibleItems.isEmpty) return;

        visibleItems.sort((a, b) => a.index.compareTo(b.index));
        int targetIndex = visibleItems.first.index == 0
            ? 0
            : visibleItems.last.index;

        final allGroups = paginatedStateAsync.value?.groupedDays;
        if (allGroups != null && targetIndex < allGroups.length) {
          final visibleDate = allGroups[targetIndex].date;
          final currentMonth = ref.read(currentVisibleMonthProvider);

          if (visibleDate.year != currentMonth.year ||
              visibleDate.month != currentMonth.month) {
            Future.microtask(() {
              if (context.mounted) {
                ref
                    .read(currentVisibleMonthProvider.notifier)
                    .set(DateTime(visibleDate.year, visibleDate.month));
              }
            });
          }
        }
      }

      itemPositionsListener.itemPositions.addListener(onListScroll);
      return () =>
          itemPositionsListener.itemPositions.removeListener(onListScroll);
    }, [paginatedStateAsync.value]);

    Future<void> scrollToMonth(DateTime month) async {
      final listNotifier = ref.read(paginatedTransactionListProvider.notifier);
      ref.read(currentVisibleMonthProvider.notifier).set(month);
      final availableMonths =
          ref.read(availableMonthsProvider).asData?.value ?? const <DateTime>[];
      final selectedIndex = availableMonths.indexWhere(
        (availableMonth) =>
            availableMonth.year == month.year &&
            availableMonth.month == month.month,
      );
      final olderMonth = selectedIndex > 0
          ? availableMonths[selectedIndex - 1]
          : null;
      final newerMonth =
          selectedIndex != -1 && selectedIndex < availableMonths.length - 1
          ? availableMonths[selectedIndex + 1]
          : null;
      final loaded = await listNotifier.ensureMonthWindowLoaded(
        month,
        olderMonth: olderMonth,
        newerMonth: newerMonth,
      );
      if (!context.mounted) return;
      if (!loaded) {
        final loadError = ref
            .read(paginatedTransactionListProvider)
            .value
            ?.loadMonthError;
        if (loadError != null) {
          showErrorSnackBar(
            context,
            'Monat konnte nicht geladen werden. Bitte versuche es erneut.',
          );
        }
        return;
      }

      final allGroups = ref
          .read(paginatedTransactionListProvider)
          .value
          ?.groupedDays;
      if (allGroups == null) return;

      final index = allGroups.indexWhere(
        (group) =>
            group.date.year == month.year && group.date.month == month.month,
      );

      if (index != -1) {
        isProgrammaticScroll.value = true;
        try {
          await itemScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        } finally {
          isProgrammaticScroll.value = false;
        }
      }
    }

    return Scaffold(
      appBar: const _TransactionAppBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transaction_screen_fab',
        tooltip: 'Ausgabe hinzufügen',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () {
          showAppBottomSheet(
            context: context,
            builder: (_) => const AddTransactionDialog(),
          );
        },
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CleanMonthSelector(onMonthSelected: scrollToMonth),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification) {
                      isUserScroll.value = notification.dragDetails != null;
                      newerPageRequestedDuringScroll.value = false;
                      olderPageRequestedDuringScroll.value = false;
                    } else if (notification is ScrollEndNotification) {
                      isUserScroll.value = false;
                    }
                    return false;
                  },
                  child: _TransactionList(
                    state: paginatedStateAsync,
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    onLoadOlderPage: () => ref
                        .read(paginatedTransactionListProvider.notifier)
                        .loadOlderPage(),
                  ),
                ),
                if (paginatedStateAsync.value?.isLoadingNewer == true)
                  const _EdgeLoadingIndicator(alignment: Alignment.topCenter),
                if (paginatedStateAsync.value?.loadNewerError != null)
                  _EdgeLoadError(
                    alignment: Alignment.topCenter,
                    message:
                        'Neuere Transaktionen konnten nicht geladen werden.',
                    onRetry: loadNewerPage,
                  ),
                if (paginatedStateAsync.value?.isLoadingMonth == true)
                  const _MonthLoadingOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthLoadingOverlay extends StatelessWidget {
  const _MonthLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: colorScheme.surface.withValues(alpha: 0.72),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Monat wird geladen'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Keine Ausgaben.',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _EdgeLoadingIndicator extends StatelessWidget {
  final Alignment alignment;

  const _EdgeLoadingIndicator({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeLoadError extends StatelessWidget {
  final Alignment alignment;
  final String message;
  final VoidCallback onRetry;

  const _EdgeLoadError({
    required this.alignment,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _TransactionAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Transaktionen'),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      actions: const [
        _NotificationCaptureAccessAction(),
        _PendingDraftsAction(),
        CloudStatusIcon(),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Theme.of(context).colorScheme.outlineVariant,
          height: 1,
        ),
      ),
    );
  }
}

class _PendingDraftsAction extends ConsumerWidget {
  const _PendingDraftsAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(pendingTransactionDraftsProvider);
    final drafts = draftsAsync.asData?.value;
    if (drafts == null || drafts.isEmpty) return const SizedBox.shrink();

    return Badge(
      label: Text('${drafts.length}'),
      child: IconButton(
        tooltip: 'Erfasste Ausgaben prüfen',
        onPressed: () => showTransactionDraftReviewSession(context, drafts),
        icon: const Icon(Icons.playlist_add_check_outlined),
      ),
    );
  }
}

class _NotificationCaptureAccessAction extends ConsumerWidget {
  const _NotificationCaptureAccessAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = ref.watch(notificationCaptureGatewayProvider);
    if (!gateway.isSupported) return const SizedBox.shrink();

    final isGranted = ref
        .watch(notificationCaptureAccessGrantedProvider)
        .asData
        ?.value;
    if (isGranted != false) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Benachrichtigungszugriff aktivieren',
      onPressed: () async {
        await gateway.openNotificationAccessSettings();
        ref.invalidate(notificationCaptureAccessGrantedProvider);
      },
      icon: const Icon(Icons.notifications_off_outlined),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final AsyncValue<PaginatedTransactionsState> state;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final VoidCallback onLoadOlderPage;

  const _TransactionList({
    required this.state,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.onLoadOlderPage,
  });

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Transaktionen konnten nicht geladen werden.'),
      ),
      data: (stateData) {
        if (stateData.groupedDays.isEmpty) return const _EmptyState();

        return Stack(
          children: [
            ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              padding: const EdgeInsets.only(bottom: 80, top: 0),
              itemCount: stateData.groupedDays.length,
              itemBuilder: (context, index) =>
                  DailyTransactionGroup(group: stateData.groupedDays[index]),
            ),
            if (stateData.isLoadingOlder)
              const _EdgeLoadingIndicator(alignment: Alignment.bottomCenter),
            if (stateData.loadOlderError != null)
              _EdgeLoadError(
                alignment: Alignment.bottomCenter,
                message: 'Weitere Transaktionen konnten nicht geladen werden.',
                onRetry: onLoadOlderPage,
              ),
          ],
        );
      },
    );
  }
}
