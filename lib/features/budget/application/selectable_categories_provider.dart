// features/budget/application/selectable_categories_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'selectable_categories_provider.g.dart';

@riverpod
Future<List<ExpenseNode>> selectableCategories(Ref ref) async {
  final nodes = await ref.watch(flatExpenseNodesProvider.future);
  return nodes.where((node) => node.type == ExpenseType.variable).toList();
}
