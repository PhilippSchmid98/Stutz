// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns all transactions for [nodeIds] within the given [year].
/// If [month] is provided, filters to that specific month; otherwise the whole year.
/// Results are sorted by date descending (newest first).

@ProviderFor(categoryTransactions)
const categoryTransactionsProvider = CategoryTransactionsFamily._();

/// Returns all transactions for [nodeIds] within the given [year].
/// If [month] is provided, filters to that specific month; otherwise the whole year.
/// Results are sorted by date descending (newest first).

final class CategoryTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppTransaction>>,
          List<AppTransaction>,
          FutureOr<List<AppTransaction>>
        >
    with
        $FutureModifier<List<AppTransaction>>,
        $FutureProvider<List<AppTransaction>> {
  /// Returns all transactions for [nodeIds] within the given [year].
  /// If [month] is provided, filters to that specific month; otherwise the whole year.
  /// Results are sorted by date descending (newest first).
  const CategoryTransactionsProvider._({
    required CategoryTransactionsFamily super.from,
    required (List<String>, int, int?) super.argument,
  }) : super(
         retry: null,
         name: r'categoryTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryTransactionsHash();

  @override
  String toString() {
    return r'categoryTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<AppTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AppTransaction>> create(Ref ref) {
    final argument = this.argument as (List<String>, int, int?);
    return categoryTransactions(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryTransactionsHash() =>
    r'bb296e55356b58ea5d6618b8e7e90ae7c5397c5b';

/// Returns all transactions for [nodeIds] within the given [year].
/// If [month] is provided, filters to that specific month; otherwise the whole year.
/// Results are sorted by date descending (newest first).

final class CategoryTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<AppTransaction>>,
          (List<String>, int, int?)
        > {
  const CategoryTransactionsFamily._()
    : super(
        retry: null,
        name: r'categoryTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns all transactions for [nodeIds] within the given [year].
  /// If [month] is provided, filters to that specific month; otherwise the whole year.
  /// Results are sorted by date descending (newest first).

  CategoryTransactionsProvider call(
    List<String> nodeIds,
    int year,
    int? month,
  ) => CategoryTransactionsProvider._(
    argument: (nodeIds, year, month),
    from: this,
  );

  @override
  String toString() => r'categoryTransactionsProvider';
}
