import 'package:flutter/material.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/budget/domain/entities/income_source.dart';
import 'package:stutz/features/budget/presentation/dialogs/add_income_dialog.dart';
import 'package:stutz/features/budget/presentation/widgets/income_item_row.dart';
import 'package:stutz/shared/widgets/add_button.dart';
import 'package:stutz/shared/widgets/section_card.dart';

class IncomeSectionCard extends StatelessWidget {
  final List<IncomeSource> incomes;
  final double monthlyTotal;
  final double yearlyTotal;

  const IncomeSectionCard({
    super.key,
    required this.incomes,
    required this.monthlyTotal,
    required this.yearlyTotal,
  });

  @override
  Widget build(BuildContext context) {
    final mainIncomes = incomes
        .where((i) => i.group == IncomeGroup.main)
        .toList();
    final additionalIncomes = incomes
        .where((i) => i.group == IncomeGroup.additional)
        .toList();

    return SectionCard(
      title: "EINNAHMEN",
      totalMonthly: monthlyTotal,
      totalYearly: yearlyTotal,
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
