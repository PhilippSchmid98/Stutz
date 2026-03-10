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

  // NEU: Das Feld für die Sortierung
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
    this.sortOrder = 0, // Standardwert bei Neuerstellung im Code
  });

  bool get isGroup => children.isNotEmpty;

  Map<String, dynamic> toFirestore() {
    return {
      'parentId': parentId,
      'name': name,
      'plannedAmount': plannedAmount,
      'interval': interval,
      'type': type,
      'sortOrder': sortOrder, // NEU: Speichern
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

      // NEU: Lazy Migration.
      // Wenn null (altes Dokument), setze 99999 (ans Ende).
      sortOrder: data['sortOrder'] ?? 99999,

      children: [], // Wird später rekursiv im Repository gefüllt
    );
  }
}
