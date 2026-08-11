// features/budget/application/selectable_categories_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/features/budget/domain/entities/expense_node.dart';
import 'package:stutz/features/budget/application/budget_providers.dart';
import 'package:stutz/features/budget/domain/enums/enums.dart';

part 'selectable_categories_provider.g.dart';

@riverpod
Future<List<ExpenseNode>> selectableCategories(Ref ref) async {
  final roots = await ref.watch(expenseTreeProvider.future);
  return _flattenTreeVariableOnly(roots);
}

// Deine Logik wandert einfach hierher
List<ExpenseNode> _flattenTreeVariableOnly(List<ExpenseNode> nodes) {
  final List<ExpenseNode> flat = [];
  for (var node in nodes) {
    if (node.type == ExpenseType.variable) flat.add(node);
    if (node.children.isNotEmpty) {
      flat.addAll(_flattenTreeVariableOnly(node.children));
    }
  }
  return flat;
}
