// smartfin/lib/features/expenses/presentation/providers/expense_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_entities.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/expense_usecases.dart';

// ── Datasource ────────────────────────────────────────────────
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>(
  (_) => ExpenseLocalDataSourceImpl(),
);

// ── Repository ────────────────────────────────────────────────
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseLocalDataSourceProvider));
});

// ── Use cases ─────────────────────────────────────────────────
final getExpenseDataProvider = Provider<GetExpenseData>((ref) {
  return GetExpenseData(ref.watch(expenseRepositoryProvider));
});

// ── Selected month state ──────────────────────────────────────
final selectedMonthProvider = StateProvider<MonthSelection>(
  (_) => const MonthSelection(year: 2026, month: 2),
);

// ── Async expense data ────────────────────────────────────────
final expenseDataProvider = FutureProvider<ExpenseData>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final useCase = ref.watch(getExpenseDataProvider);
  return useCase(month);
});