import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stutz/features/transactions/application/transaction_service.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';
import 'package:stutz/features/transactions/presentation/add_transaction_dialog.dart';
import 'package:stutz/features/transactions/presentation/widgets/daily_transaction_group.dart';
import 'package:stutz/features/transactions/presentation/widgets/month_selector.dart';
import 'package:stutz/shared/widgets/cloud_status_icon.dart';

class TransactionScreen extends HookConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemScrollController = useMemoized(ItemScrollController.new);
    final itemPositionsListener = useMemoized(ItemPositionsListener.create);
    // Mutable flag that does not trigger a rebuild – avoids circular updates
    // when _scrollToMonth drives the list programmatically.
    final isProgrammaticScroll = useRef(false);

    // Auf den neuen paginierten Provider lauschen
    final paginatedStateAsync = ref.watch(paginatedTransactionListProvider);
    final availableMonthsAsync = ref.watch(availableMonthsProvider);

    useEffect(() {
      void onListScroll() {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isEmpty) return;

        // --- 1. LOGIK FÜR INF-SCROLL (NACHLADEN) ---
        // Wenn das letzte Element sichtbar wird, nächste Seite laden
        final maxIndex = positions
            .map((e) => e.index)
            .reduce((a, b) => a > b ? a : b);
        final totalItems = paginatedStateAsync.value?.groupedDays.length ?? 0;

        if (maxIndex >= totalItems - 2) {
          // 2 Elemente Puffer vor dem Ende
          ref.read(paginatedTransactionListProvider.notifier).loadNextPage();
        }

        // --- 2. LOGIK FÜR MONATS-SELEKTION BEIM SCROLLEN ---
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
      final loaded = await listNotifier.ensureMonthLoaded(month);
      if (!context.mounted || !loaded) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Für diesen Monat konnten keine Daten geladen werden.',
              ),
              duration: Duration(seconds: 2),
            ),
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
        ref.read(currentVisibleMonthProvider.notifier).set(month);

        await itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
        isProgrammaticScroll.value = false;
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Für diesen Monat wurden keine Transaktionen gefunden.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transaktionen'),
        actions: [const CloudStatusIcon()],
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transaction_screen_fab',
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddTransactionDialog(),
          );
        },
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Month Selector wartet auf asynchrone Monate
          availableMonthsAsync.when(
            data: (_) => CleanMonthSelector(onMonthSelected: scrollToMonth),
            loading: () => const SizedBox(
              height: 50,
              child: Center(child: LinearProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(height: 50),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),

          // Listeninhalt
          Expanded(
            child: paginatedStateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Fehler: $err')),
              data: (stateData) {
                final allGroups = stateData.groupedDays;
                if (allGroups.isEmpty) return const _EmptyState();

                return ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  padding: const EdgeInsets.only(bottom: 80, top: 0),
                  itemCount:
                      allGroups.length + (stateData.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == allGroups.length) {
                      if (stateData.loadMoreError != null) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              const Text(
                                'Weitere Transaktionen konnten nicht geladen werden.',
                              ),
                              TextButton(
                                onPressed: stateData.isLoadingMore
                                    ? null
                                    : () => ref
                                          .read(
                                            paginatedTransactionListProvider
                                                .notifier,
                                          )
                                          .loadNextPage(),
                                child: const Text('Erneut versuchen'),
                              ),
                            ],
                          ),
                        );
                      }

                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final group = allGroups[index];
                    return DailyTransactionGroup(group: group);
                  },
                );
              },
            ),
          ),
        ],
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
        style: TextStyle(color: Colors.grey.shade400),
      ),
    );
  }
}
