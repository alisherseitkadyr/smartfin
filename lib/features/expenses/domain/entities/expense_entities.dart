// smartfin/lib/features/expenses/domain/entities/expense_entities.dart
import 'package:equatable/equatable.dart';

// ── Expense category ──────────────────────────────────────────
enum ExpenseCategory {
  foodDining,
  transport,
  entertainment,
  shopping,
  housing,
  health,
  income,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.foodDining:  return 'Food & Dining';
      case ExpenseCategory.transport:   return 'Transport';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.shopping:    return 'Shopping';
      case ExpenseCategory.housing:     return 'Housing';
      case ExpenseCategory.health:      return 'Health';
      case ExpenseCategory.income:      return 'Income';
      case ExpenseCategory.other:       return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.foodDining:  return '🍽️';
      case ExpenseCategory.transport:   return '🚗';
      case ExpenseCategory.entertainment: return '🎬';
      case ExpenseCategory.shopping:    return '🛍️';
      case ExpenseCategory.housing:     return '🏠';
      case ExpenseCategory.health:      return '💊';
      case ExpenseCategory.income:      return '💼';
      case ExpenseCategory.other:       return '📦';
    }
  }

  // Hex colors for donut chart segments
  int get colorValue {
    switch (this) {
      case ExpenseCategory.foodDining:  return 0xFF22C55E;
      case ExpenseCategory.transport:   return 0xFF3B82F6;
      case ExpenseCategory.entertainment: return 0xFFF59E0B;
      case ExpenseCategory.shopping:    return 0xFFEF4444;
      case ExpenseCategory.housing:     return 0xFF8B5CF6;
      case ExpenseCategory.health:      return 0xFF06B6D4;
      case ExpenseCategory.income:      return 0xFF10B981;
      case ExpenseCategory.other:       return 0xFF9CA3AF;
    }
  }
}

// ── A single transaction ──────────────────────────────────────
class Transaction extends Equatable {
  final String id;
  final String merchant;
  final ExpenseCategory category;
  final int amountTiyn;   // Amount in smallest currency unit (tiyn for ₸)
  final bool isDebit;     // false = credit/income
  final DateTime date;

  const Transaction({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amountTiyn,
    required this.isDebit,
    required this.date,
  });

  bool get isIncome => !isDebit;

  @override
  List<Object?> get props => [id, merchant, amountTiyn, date];
}

// ── Per-category breakdown item ───────────────────────────────
class CategoryBreakdown extends Equatable {
  final ExpenseCategory category;
  final int totalTiyn;
  final double percent;

  const CategoryBreakdown({
    required this.category,
    required this.totalTiyn,
    required this.percent,
  });

  @override
  List<Object?> get props => [category, totalTiyn];
}

// ── Connected bank account ────────────────────────────────────
class BankAccount extends Equatable {
  final String id;
  final String bankName;
  final String maskedNumber;   // '•••• 4821'
  final bool isLive;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.maskedNumber,
    required this.isLive,
  });

  @override
  List<Object?> get props => [id];
}

// ── Unusual spend flag ────────────────────────────────────────
class SpendFlag extends Equatable {
  final String id;
  final String description;
  final ExpenseCategory category;

  const SpendFlag({
    required this.id,
    required this.description,
    required this.category,
  });

  @override
  List<Object?> get props => [id];
}

// ── Full expenses page data ───────────────────────────────────
class ExpenseData extends Equatable {
  final BankAccount account;
  final String monthLabel;
  final int totalSpentTiyn;
  final int totalSavedTiyn;
  final double spentChangePercent;
  final double savedChangePercent;
  final String biggestCategory;
  final double biggestCategoryPercent;
  final List<SpendFlag> flags;
  final List<CategoryBreakdown> breakdown;
  final String aiInsight;
  final List<Transaction> recentTransactions;
  final String currency;

  const ExpenseData({
    required this.account,
    required this.monthLabel,
    required this.totalSpentTiyn,
    required this.totalSavedTiyn,
    required this.spentChangePercent,
    required this.savedChangePercent,
    required this.biggestCategory,
    required this.biggestCategoryPercent,
    required this.flags,
    required this.breakdown,
    required this.aiInsight,
    required this.recentTransactions,
    required this.currency,
  });

  @override
  List<Object?> get props => [account.id, monthLabel, totalSpentTiyn];
}

// ── Month navigation state ────────────────────────────────────
class MonthSelection extends Equatable {
  final int year;
  final int month;

  const MonthSelection({required this.year, required this.month});

  factory MonthSelection.now() {
    final now = DateTime.now();
    return MonthSelection(year: now.year, month: now.month);
  }

  MonthSelection prev() {
    if (month == 1) return MonthSelection(year: year - 1, month: 12);
    return MonthSelection(year: year, month: month - 1);
  }

  MonthSelection next() {
    if (month == 12) return MonthSelection(year: year + 1, month: 1);
    return MonthSelection(year: year, month: month + 1);
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  String get label {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[month]} $year';
  }

  @override
  List<Object?> get props => [year, month];
}