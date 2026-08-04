// // test/data/mappers/transaction_mapper_test.dart

// import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
// import 'package:flutter_test/flutter_test.dart';
// import 'package:stutz/data/mappers/transaction_mapper.dart';
// import 'package:stutz/domain/models/models.dart';

// void main() {
//   // ---------------------------------------------------------------------------
//   // toFirestore
//   // ---------------------------------------------------------------------------

//   group('TransactionMapper.toFirestore', () {
//     test('serializes all fields including dateTime as Timestamp', () {
//       final dt = DateTime(2025, 6, 15, 10, 30);
//       final txn = AppTransaction(
//         id: 't1',
//         expenseNodeId: 'e1',
//         amount: 49.99,
//         dateTime: dt,
//         note: 'Lunch',
//       );
//       final map = TransactionMapper.toFirestore(txn);
//       expect(map['expenseNodeId'], 'e1');
//       expect(map['amount'], 49.99);
//       expect(map['note'], 'Lunch');
//       final ts = map['dateTime'] as Timestamp;
//       expect(ts.toDate(), dt);
//     });

//     test('serializes null note', () {
//       final txn = AppTransaction(
//         id: 't1',
//         expenseNodeId: 'e1',
//         amount: 10.0,
//         dateTime: DateTime(2025, 6, 15),
//         note: null,
//       );
//       final map = TransactionMapper.toFirestore(txn);
//       expect(map['note'], isNull);
//     });

//     test('round-trips dateTime without loss', () {
//       final original = DateTime(2025, 3, 17, 8, 0, 0);
//       final txn = AppTransaction(
//         id: 't1',
//         expenseNodeId: 'e1',
//         amount: 1.0,
//         dateTime: original,
//       );
//       final map = TransactionMapper.toFirestore(txn);
//       final recovered = (map['dateTime'] as Timestamp).toDate();
//       expect(recovered, original);
//     });
//   });

//   // ---------------------------------------------------------------------------
//   // fromMap
//   // ---------------------------------------------------------------------------

//   group('TransactionMapper.fromMap', () {
//     test('parses all fields correctly', () {
//       final dt = DateTime(2025, 6, 15);
//       final data = {
//         'expenseNodeId': 'e1',
//         'amount': 75.0,
//         'dateTime': Timestamp.fromDate(dt),
//         'note': 'Groceries',
//       };
//       final txn = TransactionMapper.fromMap('t1', data);
//       expect(txn.id, 't1');
//       expect(txn.expenseNodeId, 'e1');
//       expect(txn.amount, 75.0);
//       expect(txn.dateTime, dt);
//       expect(txn.note, 'Groceries');
//     });

//     test('parses null note', () {
//       final data = {
//         'expenseNodeId': 'e1',
//         'amount': 10.0,
//         'dateTime': Timestamp.fromDate(DateTime(2025, 6, 15)),
//         'note': null,
//       };
//       final txn = TransactionMapper.fromMap('t1', data);
//       expect(txn.note, isNull);
//     });

//     test('missing expenseNodeId defaults to empty string', () {
//       final data = {
//         'amount': 10.0,
//         'dateTime': Timestamp.fromDate(DateTime(2025, 6, 15)),
//       };
//       final txn = TransactionMapper.fromMap('t1', data);
//       expect(txn.expenseNodeId, '');
//     });

//     test('integer amount is cast to double', () {
//       final data = {
//         'expenseNodeId': 'e1',
//         'amount': 50,
//         'dateTime': Timestamp.fromDate(DateTime(2025, 6, 15)),
//       };
//       final txn = TransactionMapper.fromMap('t1', data);
//       expect(txn.amount, 50.0);
//       expect(txn.amount, isA<double>());
//     });
//   });
// }
