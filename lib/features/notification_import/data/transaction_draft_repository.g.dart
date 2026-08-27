// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_draft_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionDraftRepository)
const transactionDraftRepositoryProvider =
    TransactionDraftRepositoryProvider._();

final class TransactionDraftRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionDraftRepository,
          TransactionDraftRepository,
          TransactionDraftRepository
        >
    with $Provider<TransactionDraftRepository> {
  const TransactionDraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDraftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDraftRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionDraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionDraftRepository create(Ref ref) {
    return transactionDraftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDraftRepository>(value),
    );
  }
}

String _$transactionDraftRepositoryHash() =>
    r'bfb9b35378b2c25b756dac9f45b848816c1c7376';
