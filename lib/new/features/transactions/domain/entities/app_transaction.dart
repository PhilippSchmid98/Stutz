import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stutz/new/core/utils/firestore_timestamp_converter.dart';

part 'app_transaction.freezed.dart';
part 'app_transaction.g.dart';

/// Renamed from [Transaction] to avoid collision with [cloud_firestore.Transaction].
@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String expenseNodeId,
    required double amount,
    @FirestoreTimestampConverter() required DateTime dateTime,
    String? note,
  }) = _AppTransaction;

  // 1. WICHTIG: DIESE ZEILE HAT BEI DIR GEFEHLT!
  // Ohne diese Zeile erstellt json_serializable keine .g.dart Datei.
  factory AppTransaction.fromJson(Map<String, dynamic> json) =>
      _$AppTransactionFromJson(json);

  // Ersetzt deinen "TransactionMapper.fromFirestore"
  factory AppTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    data['id'] = doc.id; // ID in die Map injizieren
    return AppTransaction.fromJson(data);
  }

  // Ersetzt deinen "TransactionMapper.toFirestore"
  // Wir nutzen hier eine Extension-Methode (siehe unten), damit das Domain-Model sauber bleibt
}

// Praktischer Helper, damit dein Repository einfach .toFirestore() aufrufen kann
extension AppTransactionFirestoreX on AppTransaction {
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Die ID wollen wir nicht im Dokument-Body speichern
    return json;
  }
}
