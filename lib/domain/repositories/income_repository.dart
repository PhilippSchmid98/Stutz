import 'package:stutz/domain/models/models.dart';

abstract class IncomeSourceRepository {
  Future<List<IncomeSource>> getAllIncomeSources();
  Stream<List<IncomeSource>> watchAllIncomeSources();

  Future<void> addIncomeSource(IncomeSource source);
  Future<void> updateIncomeSource(IncomeSource source);
  Future<void> deleteIncomeSource(String id);
}
