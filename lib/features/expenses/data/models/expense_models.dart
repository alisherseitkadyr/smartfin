// smartfin/lib/features/expenses/data/models/expense_models.dart
import '../../domain/entities/expense_entities.dart';

class TransactionModel {
  final String id;
  final String merchant;
  final String category;
  final int amountTiyn;
  final bool isDebit;
  final String dateIso;

  const TransactionModel({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amountTiyn,
    required this.isDebit,
    required this.dateIso,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> j) =>
      TransactionModel(
        id: j['id'] as String,
        merchant: j['merchant'] as String,
        category: j['category'] as String,
        amountTiyn: j['amount_tiyn'] as int,
        isDebit: j['is_debit'] as bool,
        dateIso: j['date'] as String,
      );

  Transaction toEntity() => Transaction(
        id: id,
        merchant: merchant,
        category: _parseCategory(category),
        amountTiyn: amountTiyn,
        isDebit: isDebit,
        date: DateTime.parse(dateIso),
      );

  ExpenseCategory _parseCategory(String raw) {
    switch (raw) {
      case 'food_dining':     return ExpenseCategory.foodDining;
      case 'transport':       return ExpenseCategory.transport;
      case 'entertainment':   return ExpenseCategory.entertainment;
      case 'shopping':        return ExpenseCategory.shopping;
      case 'housing':         return ExpenseCategory.housing;
      case 'health':          return ExpenseCategory.health;
      case 'income':          return ExpenseCategory.income;
      default:                return ExpenseCategory.other;
    }
  }
}
