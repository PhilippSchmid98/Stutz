// features/budget/application/selectable_categories_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stutz/core/enums/enums.dart';
import 'package:stutz/domain/models/expense_node.dart';
import '../../../../presentation/providers/budget_providers.dart'; // Wo expenseTreeProvider lebt

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
