// smartfin/lib/features/expenses/domain/repositories/expense_repository.dart
import '../entities/expense_entities.dart';

abstract class ExpenseRepository {
  /// Returns full expense data for the given month.
  Future<ExpenseData> getExpenseData(MonthSelection month);
}

