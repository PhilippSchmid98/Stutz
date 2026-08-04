// // test/presentation/providers/repository_providers_test.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:stutz/presentation/providers/repository_providers.dart';

// void main() {
//   group('transactionRepositoryProvider', () {
//     test('throws when user is not logged in (uid is null)', () {
//       final container = ProviderContainer(
//         overrides: [currentUserIdProvider.overrideWithValue(null)],
//       );
//       addTearDown(container.dispose);

//       expect(
//         () => container.read(transactionRepositoryProvider),
//         throwsA(isA<Exception>()),
//       );
//     });
//   });

//   group('expenseNodeRepositoryProvider', () {
//     test('throws when user is not logged in (uid is null)', () {
//       final container = ProviderContainer(
//         overrides: [currentUserIdProvider.overrideWithValue(null)],
//       );
//       addTearDown(container.dispose);

//       expect(
//         () => container.read(expenseNodeRepositoryProvider),
//         throwsA(isA<Exception>()),
//       );
//     });
//   });

//   group('incomeSourceRepositoryProvider', () {
//     test('throws when user is not logged in (uid is null)', () {
//       final container = ProviderContainer(
//         overrides: [currentUserIdProvider.overrideWithValue(null)],
//       );
//       addTearDown(container.dispose);

//       expect(
//         () => container.read(incomeSourceRepositoryProvider),
//         throwsA(isA<Exception>()),
//       );
//     });
//   });
// }
