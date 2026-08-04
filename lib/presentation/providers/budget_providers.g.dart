// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

@ProviderFor(expenseTree)
const expenseTreeProvider = ExpenseTreeProvider._();

/// Streams expense nodes directly from Firestore — auto-updates on any change
/// without requiring manual [ref.invalidate] calls after mutations.

final class ExpenseTreeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseNode>>,
          List<ExpenseNode>,
          Stream<List<ExpenseNode>>
        >
    with
        $FutureModifier<List<ExpenseNode>>,
        $StreamProvider<List<ExpenseNode>> {
  /// Streams expense nodes directly from Firestore — auto-updates on any change
  /// without requiring manual [ref.invalidate] calls after mutations.
  const ExpenseTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseTreeHash();

  @$internal
  @override
  $StreamProviderElement<List<ExpenseNode>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExpenseNode>> create(Ref ref) {
    return expenseTree(ref);
  }
}

String _$expenseTreeHash() => r'c0a0ba514cdbee400afe3b49d39414c2105d7d06';
