// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardMonthlyStats)
const dashboardMonthlyStatsProvider = DashboardMonthlyStatsProvider._();

final class DashboardMonthlyStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyBudgetStatus>>,
          List<MonthlyBudgetStatus>,
          FutureOr<List<MonthlyBudgetStatus>>
        >
    with
        $FutureModifier<List<MonthlyBudgetStatus>>,
        $FutureProvider<List<MonthlyBudgetStatus>> {
  const DashboardMonthlyStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardMonthlyStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardMonthlyStatsHash();

  @$internal
  @override
  $FutureProviderElement<List<MonthlyBudgetStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlyBudgetStatus>> create(Ref ref) {
    return dashboardMonthlyStats(ref);
  }
}

String _$dashboardMonthlyStatsHash() =>
    r'efbb3d3ce8b32dec9a273297e73cf51192fc933a';
