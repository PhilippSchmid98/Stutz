import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';

class CleanMonthSelector extends ConsumerStatefulWidget {
  final Function(DateTime) onMonthSelected;

  const CleanMonthSelector({super.key, required this.onMonthSelected});

  @override
  ConsumerState<CleanMonthSelector> createState() => _CleanMonthSelectorState();
}

class _CleanMonthSelectorState extends ConsumerState<CleanMonthSelector> {
  final ScrollController _scrollController = ScrollController();
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

    final totalContentWidth = months.length * _itemWidth;
    final isScrollable = totalContentWidth > screenWidth;

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

  Widget _buildScrollableList(
    List<DateTime> months,
    DateTime currentMonth,
    double screenWidth,
  ) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: months.length,
      itemBuilder: (context, index) {
        return _buildItem(months[index], currentMonth);
      },
    );
  }

  Widget _buildCenteredList(List<DateTime> months, DateTime currentMonth) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: months.map((date) => _buildItem(date, currentMonth)).toList(),
      ),
    );
  }

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
