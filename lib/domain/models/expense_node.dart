import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseNode {
  final String id;
  final String? parentId; // Added: Needed for Repository to save to DB
  final String name;
  final double? plannedAmount;
  final double? actualAmount; // Calculated field (not in DB)
  final String? type; // 'Fixed' or 'Variable'
  final String? interval; // Added: 'Monthly' or 'Yearly'
  final List<ExpenseNode> children;

  ExpenseNode({
    required this.id,
    this.parentId,
    required this.name,
    this.plannedAmount,
    this.actualAmount,
    this.type,
    this.interval,
    this.children = const [],
  });

  bool get isGroup => children.isNotEmpty;

  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'plannedAmount': plannedAmount,
      'interval': interval,
      'type': type,
    };
  }

  factory ExpenseNode.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ExpenseNode(
      id: doc.id,
      parentId: data['parentId'],
      name: data['name'] ?? 'Unbekannt',
      plannedAmount: (data['plannedAmount'] as num?)?.toDouble(),
      interval: data['interval'],
      type: data['type'],
      children: [], // Wird später gefüllt
    );
  }
}
