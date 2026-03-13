import 'package:flutter/material.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/models.dart';

class BudgetOverviewCard extends StatelessWidget {
  final List<IncomeSource> incomes;
  final List<ExpenseNode> roots;

  const BudgetOverviewCard({
    super.key,
    required this.incomes,
    required this.roots,
  });

  double _calcTotalIncome() {
    double total = 0;
    for (var i in incomes) {
      total += i.interval == PaymentInterval.monthly ? i.amount : i.amount / 12;
    }
    return total;
  }

  ({double fixed, double variable}) _calcExpensesByType(
    List<ExpenseNode> nodes,
  ) {
    double fixed = 0;
    double variable = 0;
    for (var node in nodes) {
      if (node.plannedAmount != null) {
        double amount = node.plannedAmount!;
        if (node.interval == PaymentInterval.yearly) amount /= 12;
        if (node.type == ExpenseType.fixed) {
          fixed += amount;
        } else {
          variable += amount;
        }
      }
      if (node.children.isNotEmpty) {
        final sub = _calcExpensesByType(node.children);
        fixed += sub.fixed;
        variable += sub.variable;
      }
    }
    return (fixed: fixed, variable: variable);
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _calcTotalIncome();
    final (:fixed, :variable) = _calcExpensesByType(roots);
    final totalExpenses = fixed + variable;
    final balance = totalIncome - totalExpenses;
    final isPositive = balance >= 0;
    final balanceColor = isPositive ? Colors.teal : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: balanceColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "MONATLICHES BUDGET (Ø)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${isPositive ? '+' : ''} ${balance.toStringAsFixed(2)} CHF",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: balanceColor,
            ),
          ),
          Text(
            isPositive ? "Verfügbarer Überschuss" : "Budgetdefizit",
            style: TextStyle(
              color: balanceColor.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OverviewItem(
                label: "Einnahmen",
                value: totalIncome,
                color: Colors.green,
              ),
              _OverviewItem(
                label: "Ausgaben",
                value: totalExpenses,
                color: Colors.black87,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Monatlich fix",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      fixed.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Monatlich variabel",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      variable.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
