import 'package:flutter/material.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';
import 'package:stutz/presentation/screens/budget/dialogs/add_income_dialog.dart';
import 'package:stutz/presentation/screens/budget/widgets/income_item_row.dart';
import 'package:stutz/presentation/screens/shared/add_button.dart';
import 'package:stutz/presentation/screens/shared/section_card.dart';

class IncomeSectionCard extends StatelessWidget {
  final List<IncomeSource> incomes;

  const IncomeSectionCard({super.key, required this.incomes});

  @override
  Widget build(BuildContext context) {
    final mainIncomes = incomes
        .where((i) => i.group == IncomeGroup.main)
        .toList();
    final additionalIncomes = incomes
        .where((i) => i.group == IncomeGroup.additional)
        .toList();

    double rawMonthlySum = 0;
    double rawYearlySum = 0;
    for (final item in incomes) {
      if (item.interval == PaymentInterval.monthly) {
        rawMonthlySum += item.amount;
      } else {
        rawYearlySum += item.amount;
      }
    }

    return SectionCard(
      title: "EINNAHMEN",
      totalMonthly: rawMonthlySum,
      totalYearly: rawYearlySum,
      icon: Icons.trending_up,
      iconColor: Colors.green,
      backgroundColor: Colors.green.shade50,
      onHeaderTap: null,
      children: [
        if (mainIncomes.isNotEmpty) ...[
          const SubsectionTitle(title: "Haupteinnahmen"),
          ...mainIncomes.map((i) => IncomeItemRow(item: i)),
        ],
        if (mainIncomes.isNotEmpty && additionalIncomes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.green.shade200),
          ),
        if (additionalIncomes.isNotEmpty) ...[
          const SubsectionTitle(title: "Nebeneinnahmen"),
          ...additionalIncomes.map((i) => IncomeItemRow(item: i)),
        ],
        const SizedBox(height: 16),
        AddButton(
          label: "Neue Einnahme",
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddIncomeDialog(),
          ),
          color: Colors.green,
        ),
      ],
    );
  }
}
