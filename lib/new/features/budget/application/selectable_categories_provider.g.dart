// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selectable_categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectableCategories)
const selectableCategoriesProvider = SelectableCategoriesProvider._();

final class SelectableCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseNode>>,
          List<ExpenseNode>,
          FutureOr<List<ExpenseNode>>
        >
    with
        $FutureModifier<List<ExpenseNode>>,
        $FutureProvider<List<ExpenseNode>> {
  const SelectableCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectableCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectableCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<ExpenseNode>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExpenseNode>> create(Ref ref) {
    return selectableCategories(ref);
  }
}

String _$selectableCategoriesHash() =>
    r'f2e1ee9fe8d00d4c1f0e8c6ed2d09a04e0e204bf';
