
// ─────────────────────────────────────────────────────────────
// Local data source — uses static mock data
// ─────────────────────────────────────────────────────────────
// smartfin/lib/features/expenses/data/datasources/expense_local_datasource.dart
import '../../domain/entities/expense_entities.dart';
import '../models/expense_models.dart';

abstract class ExpenseLocalDataSource {
  Future<ExpenseData> getExpenseData(MonthSelection month);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const _feb2026Transactions = [
    {
      'id': 't1', 'merchant': 'Dastarkhan Restaurant',
      'category': 'food_dining', 'amount_tiyn': 8400, 'is_debit': true,
      'date': '2026-02-16',
    },
    {
      'id': 't2', 'merchant': 'Salary Deposit',
      'category': 'income', 'amount_tiyn': 350000, 'is_debit': false,
      'date': '2026-02-15',
    },
    {
      'id': 't3', 'merchant': 'Yandex Go',
      'category': 'transport', 'amount_tiyn': 2100, 'is_debit': true,
      'date': '2026-02-15',
    },
    {
      'id': 't4', 'merchant': 'Kaspi Mall',
      'category': 'shopping', 'amount_tiyn': 24500, 'is_debit': true,
      'date': '2026-02-14',
    },
    {
      'id': 't5', 'merchant': 'Magnum',
      'category': 'food_dining', 'amount_tiyn': 11200, 'is_debit': true,
      'date': '2026-02-13',
    },
    {
      'id': 't6', 'merchant': 'Netflix',
      'category': 'entertainment', 'amount_tiyn': 5490, 'is_debit': true,
      'date': '2026-02-12',
    },
    {
      'id': 't7', 'merchant': 'Astana Metro',
      'category': 'transport', 'amount_tiyn': 600, 'is_debit': true,
      'date': '2026-02-11',
    },
    {
      'id': 't8', 'merchant': 'Rent',
      'category': 'housing', 'amount_tiyn': 120000, 'is_debit': true,
      'date': '2026-02-10',
    },
  ];

  static const _jan2026Transactions = [
    {
      'id': 'j1', 'merchant': 'Salary Deposit',
      'category': 'income', 'amount_tiyn': 350000, 'is_debit': false,
      'date': '2026-01-15',
    },
    {
      'id': 'j2', 'merchant': 'Tandyr Restaurant',
      'category': 'food_dining', 'amount_tiyn': 6500, 'is_debit': true,
      'date': '2026-01-14',
    },
    {
      'id': 'j3', 'merchant': 'Yandex Go',
      'category': 'transport', 'amount_tiyn': 1800, 'is_debit': true,
      'date': '2026-01-13',
    },
    {
      'id': 'j4', 'merchant': 'Sulpak',
      'category': 'shopping', 'amount_tiyn': 18000, 'is_debit': true,
      'date': '2026-01-12',
    },
    {
      'id': 'j5', 'merchant': 'Rent',
      'category': 'housing', 'amount_tiyn': 120000, 'is_debit': true,
      'date': '2026-01-10',
    },
  ];

  @override
  Future<ExpenseData> getExpenseData(MonthSelection month) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Select mock data based on month
    final rawTxns = (month.year == 2026 && month.month == 2)
        ? _feb2026Transactions
        : _jan2026Transactions;

    final transactions = rawTxns
        .map((j) =>
            TransactionModel.fromJson(Map<String, dynamic>.from(j)).toEntity())
        .toList();

    // Compute breakdown from transactions (debits only)
    final debits = transactions.where((t) => t.isDebit).toList();
    final total = debits.fold<int>(0, (s, t) => s + t.amountTiyn);

    final Map<ExpenseCategory, int> catTotals = {};
    for (final t in debits) {
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amountTiyn;
    }

    final breakdown = catTotals.entries
        .map((e) => CategoryBreakdown(
              category: e.key,
              totalTiyn: e.value,
              percent: total > 0 ? (e.value / total * 100) : 0,
            ))
        .toList()
      ..sort((a, b) => b.totalTiyn.compareTo(a.totalTiyn));

    final biggest = breakdown.isNotEmpty ? breakdown.first : null;

    // Flags: dummy AI-detected anomalies
    final flags = month.month == 2
        ? [
            SpendFlag(
              id: 'f1',
              description: 'Dining spend up 42% from 3-month average',
              category: ExpenseCategory.foodDining,
            ),
            SpendFlag(
              id: 'f2',
              description: '4 restaurant visits in one week',
              category: ExpenseCategory.foodDining,
            ),
            SpendFlag(
              id: 'f3',
              description: 'Shopping 35% above your usual',
              category: ExpenseCategory.shopping,
            ),
          ]
        : <SpendFlag>[];

    return ExpenseData(
      account: const BankAccount(
        id: 'hal1',
        bankName: 'Halyk Bank',
        maskedNumber: '•••• 4821',
        isLive: true,
      ),
      monthLabel: month.label,
      totalSpentTiyn: total,
      totalSavedTiyn: 45800,
      spentChangePercent: month.month == 2 ? 12.0 : -3.0,
      savedChangePercent: month.month == 2 ? -8.0 : 5.0,
      biggestCategory: biggest?.category.label ?? '—',
      biggestCategoryPercent: biggest?.percent ?? 0,
      flags: flags,
      breakdown: breakdown,
      aiInsight: month.month == 2
          ? 'Dining spend up 42% from 3-month average: 4 restaurant visits in one week — revisit your Lesson 6 budget tips.'
          : 'Spending looks healthy this month. Transport is under budget by 15%.',
      recentTransactions: transactions,
      currency: '₸',
    );
  }
}

