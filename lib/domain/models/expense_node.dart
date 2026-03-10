import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseNode {
  final String id;
  final String? parentId;
  final String name;
  final double? plannedAmount;
  final double? actualAmount; // Calculated field (not in DB)
  final String? type; // 'Fixed' or 'Variable'
  final String? interval; // 'Monthly' or 'Yearly'
  final List<ExpenseNode> children;

  // NEW: Field for sorting
  final int sortOrder;

  ExpenseNode({
    required this.id,
    this.parentId,
    required this.name,
    this.plannedAmount,
    this.actualAmount,
    this.type,
    this.interval,
    this.children = const [],
    this.sortOrder = 0, // Default value when created in code
  });

  bool get isGroup => children.isNotEmpty;

  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'plannedAmount': plannedAmount,
      'interval': interval,
      'type': type,
      'sortOrder': sortOrder, // NEW: Save
    };
  }

  factory ExpenseNode.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ExpenseNode(
      id: doc.id,
      parentId: data['parentId'],
      name: data['name'] ?? 'Unknown',
      plannedAmount: (data['plannedAmount'] as num?)?.toDouble(),
      interval: data['interval'],
      type: data['type'],

      // NEW: Lazy migration.
      // If null (old document), set to 99999 (to end).
      sortOrder: data['sortOrder'] ?? 99999,

      children: [], // Filled recursively later in repository
    );
  }
}
