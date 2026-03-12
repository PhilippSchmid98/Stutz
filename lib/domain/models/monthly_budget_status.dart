/// Budget vs. actual spending summary for a single calendar month.
class MonthlyBudgetStatus {
  final DateTime month;
  final double totalPlanned;
  final double totalSpent;

  double get percentage {
    if (totalPlanned == 0) return totalSpent > 0 ? 1.0 : 0.0;
    return totalSpent / totalPlanned;
  }

  double get remaining => totalPlanned - totalSpent;

  MonthlyBudgetStatus({
    required this.month,
    required this.totalPlanned,
    required this.totalSpent,
  });
}
