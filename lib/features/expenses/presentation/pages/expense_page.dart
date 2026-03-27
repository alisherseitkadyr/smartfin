// smartfin/lib/features/expenses/presentation/pages/expense_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/expense_entities.dart';
import '../providers/expense_providers.dart';
import '../widgets/expense_widgets.dart';

class ExpensePage extends ConsumerWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(expenseDataProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: asyncData.when(
        loading: () => const _ExpenseSkeletonLoader(),
        error: (e, _) => _ExpenseErrorView(
          onRetry: () => ref.invalidate(expenseDataProvider),
        ),
        data: (data) => _ExpenseContent(
          data: data,
          selectedMonth: selectedMonth,
        ),
      ),
    );
  }
}

// ── Loaded content ─────────────────────────────────────────────
class _ExpenseContent extends ConsumerWidget {
  final ExpenseData data;
  final MonthSelection selectedMonth;
  const _ExpenseContent(
      {required this.data, required this.selectedMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar ────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 80,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.06),
          elevation: 0.5,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),

        // ── Bank account pill ──────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: BankAccountPill(account: data.account),
          ).animate().fadeIn(duration: 300.ms),
        ),

        const SliverToBoxAdapter(
          child: Divider(height: 1),
        ),

        // ── Month navigation ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: MonthNavigator(
              selectedMonth: selectedMonth,
              onPrev: () => ref
                  .read(selectedMonthProvider.notifier)
                  .state = selectedMonth.prev(),
              onNext: selectedMonth.isCurrentMonth
                  ? null
                  : () => ref
                      .read(selectedMonthProvider.notifier)
                      .state = selectedMonth.next(),
            ),
          ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
        ),

        // ── Stats row: spent + saved ───────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: ExpenseStatsRow(data: data),
          ).animate().fadeIn(delay: 80.ms, duration: 280.ms),
        ),

        // ── Info tiles row: biggest category + flags ───────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ExpenseInfoTilesRow(data: data),
          ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
        ),

        // ── Spending breakdown section ─────────────────────
        SliverToBoxAdapter(
          child: _SectionLabel(label: 'SPENDING BREAKDOWN'),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SpendingBreakdownCard(breakdown: data.breakdown),
          ).animate().fadeIn(delay: 160.ms, duration: 280.ms),
        ),

      
        // ── Recent transactions ────────────────────────────
        SliverToBoxAdapter(
          child: _SectionLabel(label: 'RECENT TRANSACTIONS'),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                if (i >= data.recentTransactions.length) return null;
                return TransactionRow(
                  transaction: data.recentTransactions[i],
                  currency: data.currency,
                )
                    .animate(delay: Duration(milliseconds: 240 + i * 50))
                    .fadeIn(duration: 250.ms)
                    .slideX(begin: -0.03, end: 0, curve: Curves.easeOut);
              },
              childCount: data.recentTransactions.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────
class _ExpenseErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ExpenseErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Could not load expenses',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────
class _ExpenseSkeletonLoader extends StatelessWidget {
  const _ExpenseSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 80,
        left: 20, right: 20, bottom: 100,
      ),
      child: Column(
        children: [
          _Bone(height: 52),
          const SizedBox(height: 16),
          _Bone(height: 44),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _Bone(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _Bone(height: 90)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _Bone(height: 80)),
            const SizedBox(width: 12),
            Expanded(child: _Bone(height: 80)),
          ]),
          const SizedBox(height: 16),
          _Bone(height: 200),
          const SizedBox(height: 16),
          _Bone(height: 80),
          const SizedBox(height: 16),
          _Bone(height: 60),
          const SizedBox(height: 8),
          _Bone(height: 60),
          const SizedBox(height: 8),
          _Bone(height: 60),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double height;
  const _Bone({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.mutedLight,
        borderRadius: BorderRadius.circular(12),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.surface.withOpacity(0.7));
  }
}