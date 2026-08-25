import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stutz/features/transactions/application/transaction_state.dart';

class CleanMonthSelector extends HookConsumerWidget {
  final ValueChanged<DateTime> onMonthSelected;

  const CleanMonthSelector({super.key, required this.onMonthSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    const itemWidth = 80.0;
    final currentMonth = ref.watch(currentVisibleMonthProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final lastScheduledScrollKey = useRef<String?>(null);

    // Hier ist es jetzt ein AsyncValue
    final monthsAsync = ref.watch(availableMonthsProvider);

    // Wir nutzen .when(), um die 3 Zustände (Data, Loading, Error) zu behandeln
    return monthsAsync.when(
      loading: () => const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(height: 50),
      data: (months) {
        if (months.isEmpty) return const SizedBox(height: 50);

        final selectedMonth =
            months.any((month) => _isSameMonth(month, currentMonth))
            ? currentMonth
            : months.last;

        final totalContentWidth = months.length * itemWidth;
        final isScrollable = totalContentWidth > screenWidth;

        if (isScrollable) {
          final scrollKey = _monthScrollKey(months, selectedMonth);
          if (lastScheduledScrollKey.value != scrollKey) {
            lastScheduledScrollKey.value = scrollKey;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) return;

              final index = months.indexWhere(
                (month) => _isSameMonth(month, selectedMonth),
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
        }

        return SizedBox(
          height: 50,
          child: isScrollable
              ? _buildScrollableList(
                  context,
                  months,
                  selectedMonth,
                  scrollController,
                )
              : _buildCenteredList(context, months, selectedMonth),
        );
      },
    );
  }

  String _monthScrollKey(List<DateTime> months, DateTime currentMonth) {
    final monthKeys = months.map(_monthKey);
    return '${currentMonth.year}-${currentMonth.month}|${monthKeys.join('|')}';
  }

  String _monthKey(DateTime month) => '${month.year}-${month.month}';

  bool _isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMM yy', 'de_DE').format(date).replaceAll('.', '');
  }

  Widget _buildScrollableList(
    BuildContext context,
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
        return _buildItem(context, months[index], currentMonth);
      },
    );
  }

  Widget _buildCenteredList(
    BuildContext context,
    List<DateTime> months,
    DateTime currentMonth,
  ) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: months
            .map((date) => _buildItem(context, date, currentMonth))
            .toList(),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    DateTime date,
    DateTime currentMonth,
  ) {
    final isSelected = _isSameMonth(date, currentMonth);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onMonthSelected(date),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surfaceContainerLow : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isSelected ? 18 : 15,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          child: Text(_formatMonth(date)),
        ),
      ),
    );
  }
}
