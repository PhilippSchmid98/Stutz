import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_income_dialog.dart';
import 'package:stutz/shared/widgets/app_bottom_sheet.dart';

class IncomeItemRow extends StatelessWidget {
  final IncomeSource item;

  const IncomeItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isMonthly = item.interval == PaymentInterval.monthly;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => showAppBottomSheet(
        context: context,
        builder: (_) => AddIncomeDialog(existingItem: item),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.name, style: const TextStyle(fontSize: 15)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item.amount.toStringAsFixed(2)} CHF",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isMonthly ? "Monatlich" : "Jährlich",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
