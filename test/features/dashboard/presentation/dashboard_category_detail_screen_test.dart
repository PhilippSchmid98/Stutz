import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';
import 'package:stutz/features/dashboard/domain/view_models/dashboard_analysis.dart';
import 'package:stutz/features/dashboard/presentation/dashboard_category_detail_screen.dart';

void main() {
  test('uses the full year for yearly category transaction queries', () {
    final start = intervalStart(DateTime(2026, 8), PaymentInterval.yearly);
    final end = intervalEnd(DateTime(2026, 8), PaymentInterval.yearly);

    expect(start.year, 2026);
    expect(start.month, 1);
    expect(end.year, 2027);
    expect(end.month, 1);
  });

  testWidgets('renders one section card for each main category', (
    tester,
  ) async {
    const categories = [
      DashboardCategoryProgress(
        categoryId: 'household',
        categoryName: 'Haushalt',
        isGroup: true,
        actualMinor: 300,
        plannedMinor: 500,
        children: [
          DashboardCategoryProgress(
            categoryId: 'food',
            categoryName: 'Lebensmittel',
            isGroup: false,
            actualMinor: 200,
            plannedMinor: 300,
          ),
        ],
      ),
      DashboardCategoryProgress(
        categoryId: 'leisure',
        categoryName: 'Freizeit',
        isGroup: true,
        actualMinor: 50,
        plannedMinor: 200,
        children: [
          DashboardCategoryProgress(
            categoryId: 'cinema',
            categoryName: 'Kino',
            isGroup: false,
            actualMinor: 50,
            plannedMinor: 100,
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DashboardIntervalDetailScreen(
            categories: categories,
            selectedMonth: DateTime(2026, 8),
            interval: PaymentInterval.monthly,
          ),
        ),
      ),
    );

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    expect(find.text('Haushalt'), findsOneWidget);
    expect(find.text('Lebensmittel'), findsOneWidget);
    expect(find.text('Freizeit'), findsOneWidget);
    expect(find.text('Kino'), findsOneWidget);
  });
}
