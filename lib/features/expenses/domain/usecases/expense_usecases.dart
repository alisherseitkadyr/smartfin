// smartfin/lib/features/expenses/domain/usecases/expense_usecases.dart
import '../entities/expense_entities.dart';
import '../repositories/expense_repository.dart';

class GetExpenseData {
  final ExpenseRepository _repository;
  const GetExpenseData(this._repository);

  Future<ExpenseData> call(MonthSelection month) =>
      _repository.getExpenseData(month);
}