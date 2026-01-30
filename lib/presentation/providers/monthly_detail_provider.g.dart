// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthlyDetailTree)
const monthlyDetailTreeProvider = MonthlyDetailTreeFamily._();

final class MonthlyDetailTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetVsActualNode>>,
          List<BudgetVsActualNode>,
          FutureOr<List<BudgetVsActualNode>>
        >
    with
        $FutureModifier<List<BudgetVsActualNode>>,
        $FutureProvider<List<BudgetVsActualNode>> {
  const MonthlyDetailTreeProvider._({
    required MonthlyDetailTreeFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthlyDetailTreeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyDetailTreeHash();

  @override
  String toString() {
    return r'monthlyDetailTreeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BudgetVsActualNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetVsActualNode>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthlyDetailTree(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyDetailTreeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyDetailTreeHash() => r'369b2bfcd710c0bb6ecab9dcbbff698058e32b6c';

final class MonthlyDetailTreeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BudgetVsActualNode>>,
          DateTime
        > {
  const MonthlyDetailTreeFamily._()
    : super(
        retry: null,
        name: r'monthlyDetailTreeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyDetailTreeProvider call(DateTime month) =>
      MonthlyDetailTreeProvider._(argument: month, from: this);

  @override
  String toString() => r'monthlyDetailTreeProvider';
}
