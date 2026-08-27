class DashboardProgress {
  final double actual;
  final double planned;

  const DashboardProgress({required this.actual, required this.planned});

  double get remaining => planned - actual;
  double get ratio => planned <= 0 ? 0 : actual / planned;
  bool get isOverBudget => actual > planned && planned >= 0;
}

class DashboardCategoryProgress extends DashboardProgress {
  final String categoryId;
  final String categoryName;
  final bool isGroup;
  final List<DashboardCategoryProgress> children;

  const DashboardCategoryProgress({
    required this.categoryId,
    required this.categoryName,
    required this.isGroup,
    this.children = const [],
    required super.actual,
    required super.planned,
  });
}

class DashboardHistoryPoint extends DashboardProgress {
  final DateTime month;

  const DashboardHistoryPoint({
    required this.month,
    required super.actual,
    required super.planned,
  });
}

class DashboardAnalysis {
  final DateTime selectedMonth;
  final DashboardProgress monthly;
  final DashboardProgress yearly;
  final List<DashboardCategoryProgress> monthlyCategories;
  final List<DashboardCategoryProgress> yearlyCategories;
  final List<DashboardHistoryPoint> monthlyHistory;
  final List<DashboardHistoryPoint> yearlyHistory;

  const DashboardAnalysis({
    required this.selectedMonth,
    required this.monthly,
    required this.yearly,
    required this.monthlyCategories,
    required this.yearlyCategories,
    required this.monthlyHistory,
    required this.yearlyHistory,
  });
}
