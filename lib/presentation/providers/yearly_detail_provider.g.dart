// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yearly_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(yearlyDetailTree)
const yearlyDetailTreeProvider = YearlyDetailTreeFamily._();

final class YearlyDetailTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<YearlyBudgetNode>>,
          List<YearlyBudgetNode>,
          FutureOr<List<YearlyBudgetNode>>
        >
    with
        $FutureModifier<List<YearlyBudgetNode>>,
        $FutureProvider<List<YearlyBudgetNode>> {
  const YearlyDetailTreeProvider._({
    required YearlyDetailTreeFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'yearlyDetailTreeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$yearlyDetailTreeHash();

  @override
  String toString() {
    return r'yearlyDetailTreeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<YearlyBudgetNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<YearlyBudgetNode>> create(Ref ref) {
    final argument = this.argument as int;
    return yearlyDetailTree(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is YearlyDetailTreeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$yearlyDetailTreeHash() => r'fab86709ce8ab7f6e245c28005824dc6ab0a3da7';

final class YearlyDetailTreeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<YearlyBudgetNode>>, int> {
  const YearlyDetailTreeFamily._()
    : super(
        retry: null,
        name: r'yearlyDetailTreeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  YearlyDetailTreeProvider call(int year) =>
      YearlyDetailTreeProvider._(argument: year, from: this);

  @override
  String toString() => r'yearlyDetailTreeProvider';
}
