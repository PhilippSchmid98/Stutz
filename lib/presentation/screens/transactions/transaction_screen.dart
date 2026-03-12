import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/transactions/add_transaction_dialog.dart';
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
          _CleanMonthSelector(onMonthSelected: _scrollToMonth),
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
                    return _DailyTransactionGroup(group: group);
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

// -----------------------------------------------------------------------------
// NEW: Intelligent clean month selector
// -----------------------------------------------------------------------------

class _CleanMonthSelector extends ConsumerStatefulWidget {
  final Function(DateTime) onMonthSelected;

  const _CleanMonthSelector({required this.onMonthSelected});

  @override
  ConsumerState<_CleanMonthSelector> createState() =>
      _CleanMonthSelectorState();
}

class _CleanMonthSelectorState extends ConsumerState<_CleanMonthSelector> {
  final ScrollController _scrollController = ScrollController();

  // Design constant: width of an item
  final double _itemWidth = 80.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(availableMonthsProvider);
    final currentMonth = ref.watch(currentVisibleMonthProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Compute: do we need to enable scrolling?
    final totalContentWidth = months.length * _itemWidth;
    final isScrollable = totalContentWidth > screenWidth;

    // Auto-scroll logic (only run when the list is scrollable)
    if (isScrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        final index = months.indexWhere(
          (m) => m.year == currentMonth.year && m.month == currentMonth.month,
        );

        if (index != -1) {
          final targetOffset =
              (index * _itemWidth) - (screenWidth / 2) + (_itemWidth / 2);
          final maxScroll = _scrollController.position.maxScrollExtent;
          final offset = targetOffset.clamp(0.0, maxScroll);

          if ((_scrollController.offset - offset).abs() > 5) {
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        }
      });
    }

    return SizedBox(
      height: 50,
      child: isScrollable
          ? _buildScrollableList(months, currentMonth, screenWidth)
          : _buildCenteredList(months, currentMonth),
    );
  }

  // Variant A: Many items -> scrollable
  Widget _buildScrollableList(
    List<DateTime> months,
    DateTime currentMonth,
    double screenWidth,
  ) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      // Padding ensures first/last item can be centered
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: months.length,
      itemBuilder: (context, index) {
        return _buildItem(months[index], currentMonth);
      },
    );
  }

  // Variant B: Few items -> centered & static
  Widget _buildCenteredList(List<DateTime> months, DateTime currentMonth) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min, // Takes only as much space as needed
        mainAxisAlignment: MainAxisAlignment.center,
        children: months.map((date) {
          return _buildItem(date, currentMonth);
        }).toList(),
      ),
    );
  }

  // Item text design (reused)
  Widget _buildItem(DateTime date, DateTime currentMonth) {
    final isSelected =
        date.year == currentMonth.year && date.month == currentMonth.month;

    return GestureDetector(
      onTap: () => widget.onMonthSelected(date),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _itemWidth,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Roboto',
            // Active: larger & black. Inactive: smaller & grey
            fontSize: isSelected ? 18 : 15,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
          child: Text(
            DateFormat('MMM yy', 'de_DE').format(date).replaceAll('.', ''),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// --------------------------------------------------------------------------

class _DailyTransactionGroup extends StatelessWidget {
  final DailyTransactions group;
  const _DailyTransactionGroup({required this.group});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('dd.MM', 'de_DE');
    final weekDayFormat = DateFormat('EEEE', 'de_DE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8), // More padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    dayFormat.format(group.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    weekDayFormat.format(group.date),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              Text(
                '-${group.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0), // Full width look
          child: Column(
            children: group.transactions
                .map((item) => _TransactionItem(item: item))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends ConsumerWidget {
  final TransactionWithCategory item;
  const _TransactionItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AddTransactionDialog(existingItem: item),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Very subtle icon
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.categoryName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (item.transaction.note != null &&
                      item.transaction.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.transaction.note!,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '-${item.transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
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
        style: TextStyle(color: Colors.grey.shade400),
      ),
    );
  }
}
