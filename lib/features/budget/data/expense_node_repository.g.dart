// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_node_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.

@ProviderFor(expenseNodeRepository)
const expenseNodeRepositoryProvider = ExpenseNodeRepositoryProvider._();

/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.

final class ExpenseNodeRepositoryProvider
    extends
        $FunctionalProvider<
          ExpenseNodeRepository,
          ExpenseNodeRepository,
          ExpenseNodeRepository
        >
    with $Provider<ExpenseNodeRepository> {
  /// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
  const ExpenseNodeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseNodeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseNodeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseNodeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseNodeRepository create(Ref ref) {
    return expenseNodeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseNodeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseNodeRepository>(value),
    );
  }
}

String _$expenseNodeRepositoryHash() =>
    r'32cb01c106eab4761c5a006e6faa791be2520d97';
