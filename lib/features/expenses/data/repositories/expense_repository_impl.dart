// ─────────────────────────────────────────────────────────────
// Repository implementation
// ─────────────────────────────────────────────────────────────
// smartfin/lib/features/expenses/data/repositories/expense_repository_impl.dart
import '../../domain/entities/expense_entities.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _dataSource;
  const ExpenseRepositoryImpl(this._dataSource);

  @override
  Future<ExpenseData> getExpenseData(MonthSelection month) =>
      _dataSource.getExpenseData(month);
}