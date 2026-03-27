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
  const HomeGreetingHeader({super.key, required this.user});

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
                user.name,
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
                  user.name[0].toUpperCase(),
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
                  border: Border.all(color: AppColors.bg, width: 2),
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
        border: Border.all(color: AppColors.getMutedLightColor(context), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.getTextColor(context),
                              ),
                        ),
                        Text(
                          '${user.xpToNextLevel} to Level ${user.level + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.getMutedColor(context)),
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
          // Streak + topics done
          Row(
            children: [
              _MiniStat(
                emoji: '🔥',
                value: '${user.streakDays}',
                label: 'Day streak',
              ),
              _VertDivider(),
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
  const _MiniStat(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
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
        width: 1, height: 36, color: AppColors.getMutedLightColor(context));
  }
}

// ─────────────────────────────────────────────────────────────
// Quick actions 2x2 grid
// ─────────────────────────────────────────────────────────────
class QuickActionsGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onTap;
  const QuickActionsGrid(
      {super.key, required this.actions, required this.onTap});

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
          border: Border.all(color: AppColors.getMutedLightColor(context), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1)),
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
              offset: const Offset(0, 2)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '💳 Finance',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.greenDark,
                      ),
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
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: _color),
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
// Continue learning banner
// ─────────────────────────────────────────────────────────────
class ContinueLearningCard extends StatelessWidget {
  final FeaturedTopic topic;
  final VoidCallback onTap;
  const ContinueLearningCard(
      {super.key, required this.topic, required this.onTap});

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
                child: Text(topic.emoji,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Continue learning',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topic.title,
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
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.play_circle_fill_rounded,
                color: Colors.white, size: 30),
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
  const RecommendedTopicsRow(
      {super.key, required this.topics, required this.onTap});

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
          border: Border.all(color: AppColors.getMutedLightColor(context), width: 1.5),
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
            Text(topic.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(
              topic.title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(height: 1.3),
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
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: _levelColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '⭐ ${topic.xp} XP',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                ),
                const Spacer(),
                Text(
                  topic.duration,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}