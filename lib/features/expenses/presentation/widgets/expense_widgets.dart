// smartfin/lib/features/expenses/presentation/widgets/expense_widgets.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/expense_entities.dart';

// ─────────────────────────────────────────────────────────────
// Bank account pill
// ─────────────────────────────────────────────────────────────
class BankAccountPill extends StatelessWidget {
  final BankAccount account;
  const BankAccountPill({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.getMutedXLightColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Bank logo placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF004C8A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'HAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.bankName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  account.maskedNumber,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          // Live badge
          if (account.isLive)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .then()
                      .fadeOut(duration: 700.ms)
                      .then()
                      .fadeIn(duration: 700.ms),
                  const SizedBox(width: 5),
                  Text(
                    'LIVE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Month navigator row
// ─────────────────────────────────────────────────────────────
class MonthNavigator extends StatelessWidget {
  final MonthSelection selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  const MonthNavigator({
    super.key,
    required this.selectedMonth,
    required this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          _NavArrow(
            icon: Icons.chevron_left_rounded,
            onTap: onPrev,
          ),
          Expanded(
            child: Text(
              selectedMonth.label,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          _NavArrow(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
            disabled: onNext == null,
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _NavArrow(
      {required this.icon, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: disabled ? Colors.transparent : AppColors.getMutedXLightColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: disabled ? context.borderColor : AppColors.getTextColor(context),
          size: 22,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Spent / Saved stats row
// ─────────────────────────────────────────────────────────────
class ExpenseStatsRow extends StatelessWidget {
  final ExpenseData data;
  const ExpenseStatsRow({super.key, required this.data});

  String _fmt(int tiyn) =>
      Formatters.formatNumber(tiyn);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Total Spent',
          value: '${data.currency}${_fmt(data.totalSpentTiyn)}',
          changePercent: data.spentChangePercent,
          isPositiveGood: false,
          icon: Icons.arrow_upward_rounded,
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: 'Saved',
          value: '${data.currency}${_fmt(data.totalSavedTiyn)}',
          changePercent: data.savedChangePercent,
          isPositiveGood: true,
          icon: Icons.savings_rounded,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final double changePercent;
  final bool isPositiveGood;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.changePercent,
    required this.isPositiveGood,
    required this.icon,
  });

  bool get _isGood => isPositiveGood ? changePercent >= 0 : changePercent <= 0;
  Color get _changeColor => _isGood ? AppColors.green : AppColors.red;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  changePercent >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 12,
                  color: _changeColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(0)}% vs Jan',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: _changeColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Biggest category + unusual spend tiles
// ─────────────────────────────────────────────────────────────
class ExpenseInfoTilesRow extends StatelessWidget {
  final ExpenseData data;
  const ExpenseInfoTilesRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Biggest category
        Expanded(
          child: _InfoTile(
            label: 'Biggest Category',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.biggestCategory,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${data.biggestCategoryPercent.toStringAsFixed(0)}% of total',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.getMutedColor(context)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Unusual spend flags
        Expanded(
          child: _InfoTile(
            label: 'Unusual Spend',
            isAlert: data.flags.isNotEmpty,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.flags.isEmpty
                      ? 'All clear 👍'
                      : '${data.flags.length} flags',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: data.flags.isEmpty
                            ? AppColors.green
                            : AppColors.red,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.flags.isEmpty ? 'No anomalies' : 'AI detected',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.getMutedColor(context)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isAlert;
  const _InfoTile(
      {required this.label, required this.child, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAlert
              ? AppColors.red.withOpacity(0.3)
              : context.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Spending breakdown with custom donut chart
// ─────────────────────────────────────────────────────────────
class SpendingBreakdownCard extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;
  const SpendingBreakdownCard({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    // Take top 5 categories
    final top5 = breakdown.take(5).toList();
    final totalPercent = top5.fold<double>(0, (s, b) => s + b.percent);
    final otherPercent = math.max(0, 100 - totalPercent).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Donut
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(120, 120),
                  painter: _DonutPainter(
                    segments: top5,
                    otherPercent: otherPercent,
                    otherColor: context.mutedLight,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${top5.isNotEmpty ? top5.first.percent.toStringAsFixed(0) : '0'}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                    ),
                    Text(
                      'top',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.getMutedColor(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            child: Column(
              children: [
                ...top5.map(
                  (b) => _LegendRow(
                    color: Color(b.category.colorValue),
                    label: b.category.label,
                    percent: b.percent,
                  ),
                ),
                if (otherPercent > 0)
                  _LegendRow(
                    color: AppColors.getMutedLightColor(context),
                    label: 'Other',
                    percent: otherPercent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final double percent;
  const _LegendRow(
      {required this.color, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.getTextColor(context), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Custom painter for donut chart
class _DonutPainter extends CustomPainter {
  final List<CategoryBreakdown> segments;
  final double otherPercent;
  final Color otherColor;
  static const double _gap = 0.03; // radians gap between segments

  const _DonutPainter({required this.segments, required this.otherPercent, required this.otherColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.62;
    const totalAngle = 2 * math.pi;

    double startAngle = -math.pi / 2;

    void drawSegment(double percent, Color color) {
      if (percent <= 0) return;
      final sweep = (percent / 100) * totalAngle - _gap;
      if (sweep <= 0) return;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerR - innerR
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(cx, cy), radius: (outerR + innerR) / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep + _gap;
    }

    for (final seg in segments) {
      drawSegment(seg.percent, Color(seg.category.colorValue));
    }
    if (otherPercent > 0) {
      drawSegment(otherPercent, otherColor);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      segments != old.segments || otherPercent != old.otherPercent;
}

// ─────────────────────────────────────────────────────────────
// AI insight card
// ─────────────────────────────────────────────────────────────
class AiInsightCard extends StatelessWidget {
  final String insight;
  const AiInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.amber.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('⚠', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF78350F),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Transaction row
// ─────────────────────────────────────────────────────────────
class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  const TransactionRow(
      {super.key, required this.transaction, required this.currency});

  String _fmtAmount(int tiyn) =>
      Formatters.formatNumber(tiyn);

  String _fmtDate(DateTime dt) {
    return Formatters.formatDate(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final amountStr = isIncome
        ? '+$currency${_fmtAmount(transaction.amountTiyn)}'
        : '-$currency${_fmtAmount(transaction.amountTiyn)}';
    final amountColor = isIncome ? AppColors.green : AppColors.getTextColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(transaction.category.colorValue).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                transaction.category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchant,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.category.label} · ${_fmtDate(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Text(
            amountStr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}