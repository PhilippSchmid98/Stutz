// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_draft_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pendingTransactionDrafts)
const pendingTransactionDraftsProvider = PendingTransactionDraftsProvider._();

final class PendingTransactionDraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionDraft>>,
          List<TransactionDraft>,
          Stream<List<TransactionDraft>>
        >
    with
        $FutureModifier<List<TransactionDraft>>,
        $StreamProvider<List<TransactionDraft>> {
  const PendingTransactionDraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTransactionDraftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTransactionDraftsHash();

  @$internal
  @override
  $StreamProviderElement<List<TransactionDraft>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TransactionDraft>> create(Ref ref) {
    return pendingTransactionDrafts(ref);
  }
}

String _$pendingTransactionDraftsHash() =>
    r'9da5b82865ecd9a1f4c88db68892ca3002692dc0';

@ProviderFor(merchantCategorySuggestion)
const merchantCategorySuggestionProvider = MerchantCategorySuggestionFamily._();

final class MerchantCategorySuggestionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const MerchantCategorySuggestionProvider._({
    required MerchantCategorySuggestionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'merchantCategorySuggestionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$merchantCategorySuggestionHash();

  @override
  String toString() {
    return r'merchantCategorySuggestionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return merchantCategorySuggestion(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MerchantCategorySuggestionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$merchantCategorySuggestionHash() =>
    r'95abd95efc689e3b53f8bf3edae28bd059c06a6b';

final class MerchantCategorySuggestionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const MerchantCategorySuggestionFamily._()
    : super(
        retry: null,
        name: r'merchantCategorySuggestionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MerchantCategorySuggestionProvider call(String normalizedMerchant) =>
      MerchantCategorySuggestionProvider._(
        argument: normalizedMerchant,
        from: this,
      );

  @override
  String toString() => r'merchantCategorySuggestionProvider';
}

@ProviderFor(TransactionDraftMutations)
const transactionDraftMutationsProvider = TransactionDraftMutationsProvider._();

final class TransactionDraftMutationsProvider
    extends $AsyncNotifierProvider<TransactionDraftMutations, void> {
  const TransactionDraftMutationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDraftMutationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDraftMutationsHash();

  @$internal
  @override
  TransactionDraftMutations create() => TransactionDraftMutations();
}

String _$transactionDraftMutationsHash() =>
    r'13a6b47681ad1aae1a380ce8d4aaab4083d863b1';

abstract class _$TransactionDraftMutations extends $AsyncNotifier<void> {
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
