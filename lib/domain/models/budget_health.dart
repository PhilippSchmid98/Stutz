/// Summary of the user's financial health: income vs. planned expenses.
class BudgetHealth {
  final double income;
  final double expenses;
  final double balance;
  final bool isDeficit;

  BudgetHealth({required this.income, required this.expenses})
      : balance = income - expenses,
        isDeficit = (income - expenses) < 0;
}
