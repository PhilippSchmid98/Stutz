// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_source_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.

@ProviderFor(incomeSourceRepository)
const incomeSourceRepositoryProvider = IncomeSourceRepositoryProvider._();

/// Bridges to the not-yet-migrated Auth feature via the old presentation layer.

final class IncomeSourceRepositoryProvider
    extends
        $FunctionalProvider<
          IncomeSourceRepository,
          IncomeSourceRepository,
          IncomeSourceRepository
        >
    with $Provider<IncomeSourceRepository> {
  /// Bridges to the not-yet-migrated Auth feature via the old presentation layer.
  const IncomeSourceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeSourceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeSourceRepositoryHash();

  @$internal
  @override
  $ProviderElement<IncomeSourceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IncomeSourceRepository create(Ref ref) {
    return incomeSourceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IncomeSourceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IncomeSourceRepository>(value),
    );
  }
}

String _$incomeSourceRepositoryHash() =>
    r'3e8e3d67cbc6c36de1caef6fb45a04084cfae127';
