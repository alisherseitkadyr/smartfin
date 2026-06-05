// smartfin/lib/features/home/presentation/widgets/home_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/home_entities.dart';

// ─────────────────────────────────────────────────────────────
// Greeting header
// ─────────────────────────────────────────────────────────────
class HomeGreetingHeader extends StatelessWidget {
  final UserSummary user;
  final String? nameOverride;
  const HomeGreetingHeader({super.key, required this.user, this.nameOverride});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getMutedColor(context),
                ),
              ),
              Text(
                nameOverride ?? user.name,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ],
          ),
        ),
        // Avatar with level badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.greenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (nameOverride ?? user.name)[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  'Lv.${user.level}',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats row: XP bar, streak, topics progress
// ─────────────────────────────────────────────────────────────
class HomeStatsRow extends StatelessWidget {
  final UserSummary user;
  const HomeStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getMutedLightColor(context),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // XP progress
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${user.totalXp} XP',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.getTextColor(context),
                              ),
                        ),
                        Text(
                          '${user.xpToNextLevel} to Level ${user.level + 1}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.getMutedColor(context),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: user.progressToNextLevel,
                        backgroundColor: AppColors.getMutedLightColor(context),
                        color: AppColors.green,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          // Topics done + current rank (streak removed)
          Row(
            children: [
              _MiniStat(
                emoji: '✅',
                value: '${user.completedTopics}/${user.totalTopics}',
                label: 'Topics done',
              ),
              _VertDivider(),
              _MiniStat(
                emoji: '🏅',
                value: 'Level ${user.level}',
                label: 'Current rank',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _MiniStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.getMutedLightColor(context),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Quick actions 2x2 grid
// ─────────────────────────────────────────────────────────────
class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onTap;
  const QuickActionsGrid({
    super.key,
    required this.actions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, i) {
        return _QuickActionTile(action: actions[i], onTap: onTap)
            .animate(delay: Duration(milliseconds: i * 50))
            .fadeIn(duration: 250.ms)
            .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1));
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;
  final ValueChanged<QuickAction> onTap;
  const _QuickActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(action),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.getMutedLightColor(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(action.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.getTextColor2(context),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Monthly snapshot card
// ─────────────────────────────────────────────────────────────
class MonthlySnapshotCard extends StatelessWidget {
  final MonthlySnapshot snapshot;
  const MonthlySnapshotCard({super.key, required this.snapshot});

  String _fmt(int amount) {
    return Formatters.formatNumber(amount);
  }

  @override
  Widget build(BuildContext context) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                snapshot.monthLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '💳 Finance',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.greenDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SnapshotTile(
                label: 'Total Spent',
                value: '${snapshot.currency}${_fmt(snapshot.totalSpent)}',
                changePercent: snapshot.spentChangePercent,
                isPositiveGood: false,
              ),
              const SizedBox(width: 12),
              _SnapshotTile(
                label: 'Saved',
                value: '${snapshot.currency}${_fmt(snapshot.totalSaved)}',
                changePercent: snapshot.savedChangePercent,
                isPositiveGood: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  final String label;
  final String value;
  final double changePercent;
  final bool isPositiveGood;
  const _SnapshotTile({
    required this.label,
    required this.value,
    required this.changePercent,
    required this.isPositiveGood,
  });

  bool get _isGood => isPositiveGood ? changePercent >= 0 : changePercent <= 0;
  String get _sign => changePercent >= 0 ? '+' : '';
  Color get _color => _isGood ? AppColors.green : AppColors.red;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.getMutedXLightColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  changePercent >= 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: _color,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  '$_sign${changePercent.abs().toStringAsFixed(0)}% vs last',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: _color),
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
// Test money tips card. Delete this block + its HomePage insert to remove.
// ─────────────────────────────────────────────────────────────
class RotatingMoneyTipCard extends StatefulWidget {
  const RotatingMoneyTipCard({super.key});

  @override
  State<RotatingMoneyTipCard> createState() => _RotatingMoneyTipCardState();
}

class _RotatingMoneyTipCardState extends State<RotatingMoneyTipCard> {
  int _index = 0;

  void _showNextTip() {
    setState(() => _index = (_index + 1) % _kHomeMoneyTips.length);
  }

  @override
  Widget build(BuildContext context) {
    final tip = _kHomeMoneyTips[_index];

    return Semantics(
      button: true,
      label: 'Show next money tip',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        reverseDuration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: _MoneyTipCard(
          key: ValueKey(tip.title),
          tip: tip,
          index: _index,
          total: _kHomeMoneyTips.length,
          onTap: _showNextTip,
        ),
      ),
    );
  }
}

class _MoneyTipCard extends StatelessWidget {
  final _HomeMoneyTip tip;
  final int index;
  final int total;
  final VoidCallback onTap;

  const _MoneyTipCard({
    super.key,
    required this.tip,
    required this.index,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardColor = isDark ? tip.accent.withValues(alpha: 0.12) : tip.bg;
    final borderColor = tip.accent.withValues(alpha: isDark ? 0.36 : 0.24);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tip.accent.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tip.icon, color: tip.accent, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Money tip',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: tip.accent,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${index + 1}/$total',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.getMutedColor(context),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      tip.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tip.body,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getTextColor2(context),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _TipProgressDots(
                          count: total,
                          activeIndex: index,
                          color: tip.accent,
                        ),
                        const Spacer(),
                        Text(
                          'Tap for next',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: tip.accent,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: tip.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipProgressDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final Color color;

  const _TipProgressDots({
    required this.count,
    required this.activeIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 16 : 5,
          height: 5,
          margin: EdgeInsets.only(right: i == count - 1 ? 0 : 4),
          decoration: BoxDecoration(
            color: isActive ? color : AppColors.getMutedLightColor(context),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _HomeMoneyTip {
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Color bg;

  const _HomeMoneyTip({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    required this.bg,
  });
}

const _kHomeMoneyTips = [
  _HomeMoneyTip(
    title: 'Pay yourself first',
    body:
        'Move a small amount to savings when income arrives, before daily spending begins.',
    icon: Icons.savings_rounded,
    accent: AppColors.greenDark,
    bg: AppColors.greenLight,
  ),
  _HomeMoneyTip(
    title: 'Use a 24-hour pause',
    body:
        'For non-essential purchases, wait one day. If you still want it, buy with a clear head.',
    icon: Icons.hourglass_bottom_rounded,
    accent: AppColors.amberDark,
    bg: AppColors.amberLight,
  ),
  _HomeMoneyTip(
    title: 'Name every account',
    body:
        'Labels like Rent, Emergency, or Trip make money feel assigned, not available.',
    icon: Icons.account_balance_wallet_rounded,
    accent: AppColors.blueDark,
    bg: AppColors.blueLight,
  ),
  _HomeMoneyTip(
    title: 'Protect the boring money',
    body:
        'Emergency savings should be easy to reach, but separate from your spending card.',
    icon: Icons.shield_rounded,
    accent: AppColors.indigoDark,
    bg: AppColors.indigoLight,
  ),
];

// ─────────────────────────────────────────────────────────────
// Continue learning banner
// ─────────────────────────────────────────────────────────────
class ContinueLearningCard extends StatelessWidget {
  final FeaturedTopic topic;
  final VoidCallback onTap;
  const ContinueLearningCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F4C2A), Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenDark.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(topic.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.subtopicTitle != null
                        ? topic.title
                        : 'Continue learning',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topic.subtopicTitle ?? topic.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: topic.progressPercent,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            color: Colors.white,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(topic.progressPercent * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Recommended topics horizontal scroll
// ─────────────────────────────────────────────────────────────
class RecommendedTopicsRow extends StatelessWidget {
  final List<FeaturedTopic> topics;
  final ValueChanged<String> onTap;
  const RecommendedTopicsRow({
    super.key,
    required this.topics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 166,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return _RecommendedCard(topic: topics[i], onTap: onTap)
              .animate(delay: Duration(milliseconds: i * 60))
              .fadeIn(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
        },
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final FeaturedTopic topic;
  final ValueChanged<String> onTap;
  const _RecommendedCard({required this.topic, required this.onTap});

  Color get _levelColor {
    switch (topic.level) {
      case 'Intermediate':
        return AppColors.blue;
      case 'Advanced':
        return AppColors.navy;
      default:
        return AppColors.greenDark;
    }
  }

  Color get _levelBg {
    switch (topic.level) {
      case 'Intermediate':
        return AppColors.blueLight;
      case 'Advanced':
        return const Color(0xFFEEF2FF);
      default:
        return AppColors.greenLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(topic.topicId),
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getMutedLightColor(context),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(topic.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              topic.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Level chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _levelBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                topic.level,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: _levelColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '⭐ ${topic.xp} XP',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
                ),
                const Spacer(),
                Text(
                  topic.duration,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
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
// Repeat topics row
// ─────────────────────────────────────────────────────────────

class RepeatTopicsRow extends StatelessWidget {
  final List<FeaturedTopic> topics;
  final ValueChanged<String> onTap;
  const RepeatTopicsRow({
    super.key,
    required this.topics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return _RepeatCard(topic: topics[i], onTap: onTap)
              .animate(delay: Duration(milliseconds: i * 60))
              .fadeIn(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, curve: Curves.easeOut);
        },
      ),
    );
  }
}

class _RepeatCard extends StatelessWidget {
  final FeaturedTopic topic;
  final ValueChanged<String> onTap;
  const _RepeatCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(topic.topicId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.greenMid.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(topic.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: Text(
                    topic.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '✅ Completed • ⭐ ${topic.xp} XP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.greenDark,
                      ),
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
// Finance news / articles section
// ─────────────────────────────────────────────────────────────

class _FinanceArticle {
  final String tag;
  final Color tagColor;
  final Color tagBg;
  final String emoji;
  final String title;
  final String summary;
  final String readTime;

  const _FinanceArticle({
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.emoji,
    required this.title,
    required this.summary,
    required this.readTime,
  });
}

const _kArticles = [
  _FinanceArticle(
    tag: 'Budgeting',
    tagColor: AppColors.greenDark,
    tagBg: AppColors.greenLight,
    emoji: '💡',
    title: '5 Ways to Cut Spending Without Feeling Deprived',
    summary:
        'Small habit shifts that free up hundreds each month — without giving up the things you love.',
    readTime: '3 min',
  ),
  _FinanceArticle(
    tag: 'Saving',
    tagColor: Color(0xFF0369A1),
    tagBg: Color(0xFFE0F2FE),
    emoji: '🛡️',
    title: 'Why Your Emergency Fund Needs Its Own Account',
    summary:
        'Keeping your safety net separate prevents accidental spending and builds a psychological barrier.',
    readTime: '2 min',
  ),
  _FinanceArticle(
    tag: 'Investing',
    tagColor: Color(0xFF7C3AED),
    tagBg: Color(0xFFEDE9FE),
    emoji: '📈',
    title: 'The Magic of Compound Interest Explained Simply',
    summary:
        'Why starting to invest ten years earlier can double your retirement wealth — with real numbers.',
    readTime: '4 min',
  ),
  _FinanceArticle(
    tag: 'Credit',
    tagColor: Color(0xFFB45309),
    tagBg: Color(0xFFFEF3C7),
    emoji: '📊',
    title: 'The One Habit That Boosts Your Credit Score Fast',
    summary:
        'Payment history is 35% of your score. Here is a simple system to never miss a due date again.',
    readTime: '3 min',
  ),
  _FinanceArticle(
    tag: 'Security',
    tagColor: Color(0xFFDC2626),
    tagBg: Color(0xFFFEF2F2),
    emoji: '🔒',
    title: 'How to Spot a Financial Scam Before It Costs You',
    summary:
        'Fraudsters are getting smarter. These five red flags catch 90% of phishing and social-engineering attacks.',
    readTime: '2 min',
  ),
];

class FinanceNewsSection extends StatelessWidget {
  const FinanceNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _kArticles.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ArticleCard(article: e.value)
                .animate(delay: Duration(milliseconds: e.key * 70))
                .fadeIn(duration: 280.ms)
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOut,
                ),
          );
        }).toList(),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _FinanceArticle article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: article.tagBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    article.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: article.tagBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Sora',
                              color: article.tagColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          article.readTime,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.summary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.getMutedColor(context),
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
