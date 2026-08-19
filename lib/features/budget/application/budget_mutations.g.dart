// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_mutations.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetMutations)
const budgetMutationsProvider = BudgetMutationsProvider._();

final class BudgetMutationsProvider
    extends $AsyncNotifierProvider<BudgetMutations, void> {
  const BudgetMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetMutationsHash();

  @$internal
  @override
  BudgetMutations create() => BudgetMutations();
}

String _$budgetMutationsHash() => r'3a141db38f357b5e4e0d2f1c055c652a893d8436';

abstract class _$BudgetMutations extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
