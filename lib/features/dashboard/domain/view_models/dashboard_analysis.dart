class DashboardProgress {
  final int actualMinor;
  final int plannedMinor;

  const DashboardProgress({
    required this.actualMinor,
    required this.plannedMinor,
  });

  int get remainingMinor => plannedMinor - actualMinor;
  double get ratio => plannedMinor <= 0 ? 0 : actualMinor / plannedMinor;
  bool get isOverBudget => actualMinor > plannedMinor && plannedMinor >= 0;
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
    required super.actualMinor,
    required super.plannedMinor,
  });
}

class DashboardHistoryPoint extends DashboardProgress {
  final DateTime month;

  const DashboardHistoryPoint({
    required this.month,
    required super.actualMinor,
    required super.plannedMinor,
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
