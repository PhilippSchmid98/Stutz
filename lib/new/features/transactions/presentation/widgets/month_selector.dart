import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/presentation/providers/transaction_providers.dart';

class CleanMonthSelector extends HookConsumerWidget {
  final Function(DateTime) onMonthSelected;

  const CleanMonthSelector({super.key, required this.onMonthSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    const itemWidth = 80.0;

    final months = ref.watch(availableMonthsProvider);
    final currentMonth = ref.watch(currentVisibleMonthProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final totalContentWidth = months.length * itemWidth;
    final isScrollable = totalContentWidth > screenWidth;

    if (isScrollable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;

        final index = months.indexWhere(
          (m) => m.year == currentMonth.year && m.month == currentMonth.month,
        );

        if (index != -1) {
          final targetOffset =
              (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
          final maxScroll = scrollController.position.maxScrollExtent;
          final offset = targetOffset.clamp(0.0, maxScroll);

          if ((scrollController.offset - offset).abs() > 5) {
            scrollController.animateTo(
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
          ? _buildScrollableList(months, currentMonth, scrollController)
          : _buildCenteredList(months, currentMonth),
    );
  }

  Widget _buildScrollableList(
    List<DateTime> months,
    DateTime currentMonth,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      controller: scrollController,
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
      onTap: () => onMonthSelected(date),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 80,
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
