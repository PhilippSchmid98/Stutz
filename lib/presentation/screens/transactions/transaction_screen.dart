import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';
import 'package:stutz/presentation/screens/transactions/add_transaction_dialog.dart';
import 'package:stutz/presentation/screens/transactions/widgets/daily_transaction_group.dart';
import 'package:stutz/presentation/screens/transactions/widgets/month_selector.dart';
import 'package:stutz/presentation/screens/widgets/cloud_status_icon.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onListScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onListScroll);
    super.dispose();
  }

  void _onListScroll() {
    if (_isProgrammaticScroll) return;

    final positions = _itemPositionsListener.itemPositions.value;
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
          if (mounted) {
            ref
                .read(currentVisibleMonthProvider.notifier)
                .set(DateTime(visibleDate.year, visibleDate.month));
          }
        });
      }
    }
  }

  Future<void> _scrollToMonth(DateTime month) async {
    final allGroups = ref.read(transactionListProvider).value;
    if (allGroups == null) return;

    final index = allGroups.indexWhere(
      (group) =>
          group.date.year == month.year && group.date.month == month.month,
    );

    if (index != -1) {
      _isProgrammaticScroll = true;
      ref.read(currentVisibleMonthProvider.notifier).set(month);

      await _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );

      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) _isProgrammaticScroll = false;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Keine Transaktionen in diesem Monat"),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionListAsync = ref.watch(transactionListProvider);

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
          CleanMonthSelector(onMonthSelected: _scrollToMonth),
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
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
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
