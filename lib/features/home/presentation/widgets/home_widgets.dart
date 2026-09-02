// smartfin/lib/features/home/presentation/widgets/home_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../domain/entities/home_entities.dart';
import '../../domain/entities/home_tip.dart';
import '../providers/home_providers.dart';

// ─────────────────────────────────────────────────────────────
// Greeting header
// ─────────────────────────────────────────────────────────────
class HomeGreetingHeader extends ConsumerWidget {
  final UserSummary user;
  const HomeGreetingHeader({super.key, required this.user});

  String _greeting(AppL10n l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final first = user.name.isNotEmpty ? user.name.split(' ').first : 'there';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting(l10n)},',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.getMutedColor(context),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  first,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HeaderChip(
                label: 'Level ${user.level}',
                bg: isDark ? const Color(0xFF0D3320) : AppColors.greenLight,
                fg: AppColors.greenDark,
              ),
              const SizedBox(height: 6),
              _HeaderChip(
                label: l10n.streakChip(user.streakDays),
                bg: isDark ? const Color(0xFF3D2A00) : AppColors.amberLight,
                fg: const Color(0xFFD97706),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _HeaderChip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats row: XP bar, streak, topics progress
// ─────────────────────────────────────────────────────────────
class HomeStatsRow extends ConsumerWidget {
  final UserSummary user;
  const HomeStatsRow({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
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
            color: Colors.black.withValues(alpha: 0.04),
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
                          l10n.xpToLevelLabel(user.xpToNextLevel, user.level + 1),
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
                label: l10n.topicsDoneLabel,
              ),
              _VertDivider(),
              _MiniStat(
                emoji: '🏅',
                value: 'Level ${user.level}',
                label: l10n.currentRankLabel,
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
              color: Colors.black.withValues(alpha: 0.04),
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
// Money tip card — backend-driven, tap to fetch a new random tip
// ─────────────────────────────────────────────────────────────
class MoneyTipCard extends ConsumerWidget {
  const MoneyTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(homeTipProvider);
    final l10n = ref.watch(appL10nProvider);

    return tipAsync.when(
      loading: () => const _TipCardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tip) => Semantics(
        button: true,
        label: l10n.showNextMoneyTip,
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
                  scale:
                      Tween<double>(begin: 0.98, end: 1).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: _MoneyTipCard(
            key: ValueKey(tip.id),
            tip: tip,
            l10n: l10n,
            onTap: () => ref.invalidate(homeTipProvider),
          ),
        ),
      ),
    );
  }
}

class _MoneyTipCard extends StatelessWidget {
  final HomeTip tip;
  final VoidCallback onTap;
  final AppL10n l10n;

  const _MoneyTipCard({
    super.key,
    required this.tip,
    required this.l10n,
    required this.onTap,
  });

  IconData _resolveIcon(String key) => switch (key) {
        'savings' => Icons.savings_rounded,
        'shield' => Icons.shield_rounded,
        'wallet' => Icons.account_balance_wallet_rounded,
        'hourglass' => Icons.hourglass_bottom_rounded,
        'chart' => Icons.show_chart_rounded,
        _ => Icons.lightbulb_outline_rounded,
      };

  ({Color accent, Color bg}) _resolveColors(TipTheme theme) => switch (theme) {
        TipTheme.amber => (accent: AppColors.amberDark, bg: AppColors.amberLight),
        TipTheme.blue => (accent: AppColors.blueDark, bg: AppColors.blueLight),
        TipTheme.indigo =>
          (accent: AppColors.indigoDark, bg: AppColors.indigoLight),
        TipTheme.green => (accent: AppColors.greenDark, bg: AppColors.greenLight),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final colors = _resolveColors(tip.theme);
    final accent = colors.accent;
    final cardColor = isDark ? accent.withValues(alpha: 0.12) : colors.bg;
    final borderColor = accent.withValues(alpha: isDark ? 0.36 : 0.24);

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
                  color: accent.withValues(alpha: isDark ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_resolveIcon(tip.iconKey), color: accent, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.moneyTip,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      tip.title,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        const Spacer(),
                        Text(
                          l10n.tapForNext,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: accent,
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

class _TipCardSkeleton extends StatelessWidget {
  const _TipCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: context.mutedLight,
        borderRadius: BorderRadius.circular(18),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Theme.of(context)
              .colorScheme
              .surface
              .withValues(alpha: 0.7),
        );
  }
}

// ─────────────────────────────────────────────────────────────
// Continue learning banner
// ─────────────────────────────────────────────────────────────
class ContinueLearningCard extends ConsumerWidget {
  final FeaturedTopic topic;
  final VoidCallback onTap;
  const ContinueLearningCard({
    super.key,
    required this.topic,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
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
              color: AppColors.greenDark.withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _HomeTopicIcon(emoji: topic.emoji, iconPath: topic.iconPath, size: 26),
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
                        : l10n.continueLearning,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
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
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            color: Colors.white,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(topic.progressPercent * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
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

class _RecommendedCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    String formatDuration(String raw) {
      final m = RegExp(r"(\\d+)").firstMatch(raw);
      if (m != null) {
        final minutes = int.tryParse(m.group(1)!);
        if (minutes != null) return l10n.minutesLabel(minutes);
      }
      return raw;
    }
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeTopicIcon(emoji: topic.emoji, iconPath: topic.iconPath, size: 26),
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
                  formatDuration(topic.duration),
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

class _RepeatCard extends ConsumerWidget {
  final FeaturedTopic topic;
  final ValueChanged<String> onTap;
  const _RepeatCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
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
            _HomeTopicIcon(emoji: topic.emoji, iconPath: topic.iconPath, size: 22),
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
                  l10n.completedXpLabel(topic.xp),
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

class _HomeTopicIcon extends StatelessWidget {
  final String emoji;
  final String? iconPath;
  final double size;

  const _HomeTopicIcon({required this.emoji, this.iconPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    if (path != null && path.isNotEmpty) {
      return path.startsWith('http')
          ? Image.network(path, width: size, height: size, fit: BoxFit.contain)
          : Image.asset(path, width: size, height: size, fit: BoxFit.contain);
    }
    return Text(emoji, style: TextStyle(fontSize: size));
  }
}
