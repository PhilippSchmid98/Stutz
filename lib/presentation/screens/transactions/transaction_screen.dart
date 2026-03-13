import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';
import 'package:stutz/presentation/screens/transactions/add_transaction_dialog.dart';
import 'package:stutz/presentation/screens/transactions/widgets/daily_transaction_group.dart';
import 'package:stutz/presentation/screens/transactions/widgets/month_selector.dart';
import 'package:stutz/presentation/screens/widgets/cloud_status_icon.dart';

class TransactionScreen extends HookConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemScrollController = useMemoized(ItemScrollController.new);
    final itemPositionsListener =
        useMemoized(ItemPositionsListener.create);
    // Mutable flag that does not trigger a rebuild – avoids circular updates
    // when _scrollToMonth drives the list programmatically.
    final isProgrammaticScroll = useRef(false);

    final transactionListAsync = ref.watch(transactionListProvider);

    // Register / deregister the scroll-position listener exactly once.
    useEffect(() {
      void onListScroll() {
        if (isProgrammaticScroll.value) return;

        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isEmpty) return;

        // 1. Filter: only items that are actually visible
        final visibleItems = positions.where((pos) {
          return pos.itemLeadingEdge < 1 && pos.itemTrailingEdge > 0;
        }).toList();

        if (visibleItems.isEmpty) return;

        // 2. Sort by index (so we know which item is top or bottom)
        // index 0 = top
        visibleItems.sort((a, b) => a.index.compareTo(b.index));

        int targetIndex;

        // --- Logic ---

        // RULE 1: If we're at the very top of the list, choose index 0.
        // This prevents incorrect month selection when few items are present near the top.
        if (visibleItems.first.index == 0) {
          targetIndex = 0;
        } else {
          // RULE 2: Otherwise, consider the bottom-most visible item.
          // When a new month scrolls in at the bottom, update to that month.
          targetIndex = visibleItems.last.index;
        }

        // --- STATE UPDATE ---

        final allGroups = ref.read(transactionListProvider).value;

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
    }, const []);

    Future<void> scrollToMonth(DateTime month) async {
      final allGroups = ref.read(transactionListProvider).value;
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

        Future.delayed(const Duration(milliseconds: 650), () {
          if (context.mounted) isProgrammaticScroll.value = false;
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Keine Transaktionen in diesem Monat"),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white, // Cleaner background
      appBar: AppBar(
        title: const Text('Transaktionen'),
        actions: [const CloudStatusIcon()],
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // Hide AppBar divider for a seamless look with the month selector
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
            // use builder to provide a dialog widget
            builder: (_) => const AddTransactionDialog(),
          );
        },
      ),
      body: Column(
        children: [
          // New: Clean month selector
          const SizedBox(height: 8),
          CleanMonthSelector(onMonthSelected: scrollToMonth),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade100),

          // List
          Expanded(
            child: transactionListAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Fehler: $err')),
              data: (allGroups) {
                if (allGroups.isEmpty) return const _EmptyState();

                return ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  padding: const EdgeInsets.only(bottom: 80, top: 0),
                  itemCount: allGroups.length,
                  itemBuilder: (context, index) {
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
