import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_income_dialog.dart';

class IncomeItemRow extends StatelessWidget {
  final IncomeSource item;

  const IncomeItemRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isMonthly = item.interval == PaymentInterval.monthly;

    return InkWell(
      onTap: () => showDialog(
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
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.name, style: const TextStyle(fontSize: 15)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isMonthly ? "Monatlich" : "Jährlich",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
