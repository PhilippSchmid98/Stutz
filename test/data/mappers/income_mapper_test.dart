// // test/data/mappers/income_mapper_test.dart

// import 'package:flutter_test/flutter_test.dart';
// import 'package:stutz/core/enums/enums.dart';
// import 'package:stutz/data/mappers/income_mapper.dart';
// import 'package:stutz/domain/models/models.dart';

// void main() {
//   // ---------------------------------------------------------------------------
//   // toFirestore
//   // ---------------------------------------------------------------------------

//   group('IncomeMapper.toFirestore', () {
//     test('serializes monthly main income', () {
//       final source = IncomeSource(
//         id: 'i1',
//         name: 'Salary',
//         amount: 5000.0,
//         interval: PaymentInterval.monthly,
//         group: IncomeGroup.main,
//       );
//       final map = IncomeMapper.toFirestore(source);
//       expect(map['name'], 'Salary');
//       expect(map['amount'], 5000.0);
//       expect(map['interval'], 'monthly');
//       expect(map['group'], 'main');
//     });

//     test('serializes yearly interval', () {
//       final source = IncomeSource(
//         id: 'i1',
//         name: 'Bonus',
//         amount: 12000.0,
//         interval: PaymentInterval.yearly,
//       );
//       final map = IncomeMapper.toFirestore(source);
//       expect(map['interval'], 'yearly');
//     });

//     test('serializes additional group', () {
//       final source = IncomeSource(
//         id: 'i1',
//         name: 'Freelance',
//         amount: 800.0,
//         group: IncomeGroup.additional,
//       );
//       final map = IncomeMapper.toFirestore(source);
//       expect(map['group'], 'additional');
//     });
//   });

//   // ---------------------------------------------------------------------------
//   // fromMap
//   // ---------------------------------------------------------------------------

//   group('IncomeMapper.fromMap', () {
//     test('parses all fields correctly', () {
//       final data = {
//         'name': 'Salary',
//         'amount': 5000.0,
//         'interval': 'monthly',
//         'group': 'main',
//       };
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.id, 'i1');
//       expect(source.name, 'Salary');
//       expect(source.amount, 5000.0);
//       expect(source.interval, PaymentInterval.monthly);
//       expect(source.group, IncomeGroup.main);
//     });

//     test('parses yearly interval', () {
//       final data = {'name': 'X', 'amount': 100.0, 'interval': 'yearly'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.interval, PaymentInterval.yearly);
//     });

//     test('parses additional group', () {
//       final data = {'name': 'X', 'amount': 100.0, 'group': 'additional'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.group, IncomeGroup.additional);
//     });

//     test('defaults to monthly when interval missing', () {
//       final data = {'name': 'X', 'amount': 100.0};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.interval, PaymentInterval.monthly);
//     });

//     test('defaults to main when group missing', () {
//       final data = {'name': 'X', 'amount': 100.0};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.group, IncomeGroup.main);
//     });

//     test('unknown interval falls back to monthly', () {
//       final data = {'name': 'X', 'amount': 100.0, 'interval': 'quarterly'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.interval, PaymentInterval.monthly);
//     });

//     test('unknown group falls back to main', () {
//       final data = {'name': 'X', 'amount': 100.0, 'group': 'secondary'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.group, IncomeGroup.main);
//     });

//     test('backward compat: PascalCase interval parses correctly', () {
//       final data = {'name': 'X', 'amount': 100.0, 'interval': 'Yearly'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.interval, PaymentInterval.yearly);
//     });

//     test('backward compat: PascalCase group parses correctly', () {
//       final data = {'name': 'X', 'amount': 100.0, 'group': 'Additional'};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.group, IncomeGroup.additional);
//     });

//     test('empty name defaults to empty string', () {
//       final data = {'amount': 100.0};
//       final source = IncomeMapper.fromMap('i1', data);
//       expect(source.name, '');
//     });
//   });
// }
