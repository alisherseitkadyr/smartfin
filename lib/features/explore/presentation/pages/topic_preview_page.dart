import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/progress_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../learn/domain/entities/lesson_topic.dart';
import '../../../learn/presentation/providers/lesson_flow_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import '../providers/explore_providers.dart';

class TopicPreviewPage extends ConsumerWidget {
  final String topicId;
  final CategoryColor? categoryColor;

  const TopicPreviewPage({
    super.key,
    required this.topicId,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicAsync = ref.watch(singleTopicProvider(topicId));
    final lessonAsync = ref.watch(lessonForTopicProvider(topicId));

    return topicAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (topic) {
        if (topic == null) {
          return const Scaffold(
            body: Center(child: Text('Topic not found')),
          );
        }
        return _PreviewBody(
          topicWithStatus: topic,
          outcomes: lessonAsync.valueOrNull?.outcomes ?? [],
          categoryColor: categoryColor,
        );
      },
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  final TopicWithStatus topicWithStatus;
  final List<LessonOutcome> outcomes;
  final CategoryColor? categoryColor;

  const _PreviewBody({
    required this.topicWithStatus,
    required this.outcomes,
    this.categoryColor,
  });

  Color _heroBg() {
    switch (categoryColor) {
      case CategoryColor.blue:  return AppColors.blueLight;
      case CategoryColor.navy:  return const Color(0xFFEEF2FF);
      case CategoryColor.green: return AppColors.greenLight;
      default:                  return AppColors.greenLight;
    }
  }

  Color _heroAccent() {
    switch (categoryColor) {
      case CategoryColor.blue:  return const Color(0xFF1D4ED8);
      case CategoryColor.navy:  return AppColors.navy;
      case CategoryColor.green: return AppColors.greenDark;
      default:                  return AppColors.greenDark;
    }
  }

  Future<void> _handleStart(BuildContext context, WidgetRef ref) async {
    final t = topicWithStatus.topic;
    // POST to backend
    await ref.read(exploreRepositoryProvider).recordTopicStarted(t.id);
    // Update in-memory progress for immediate UI feedback
    ref.read(progressNotifierProvider.notifier).startTopic(ActiveTopic(
      id: t.id,
      title: t.title,
      icon: t.icon,
      level: t.level.label,
      xp: t.xp,
      duration: t.duration,
      completedSteps: 0,
      totalSteps: t.stepCount,
    ));
    // Refresh home so Continue Learning card appears
    ref.invalidate(homeDataProvider);
    if (context.mounted) context.push('/learn/lesson/${t.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = topicWithStatus.isCompleted;
    final isInProgress = topicWithStatus.isInProgress;

    final ctaLabel = isCompleted
        ? 'Completed ✓'
        : isInProgress
            ? 'Continue Learning'
            : 'Start Learning';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero section ──────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroSection(
                  topicWithStatus: topicWithStatus,
                  heroBg: _heroBg(),
                  heroAccent: _heroAccent(),
                ),
              ),

              // ── Outcomes section ──────────────────────────────
              if (outcomes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Text(
                      'WHAT YOU\'LL LEARN',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: AppColors.getMutedColor(context),
                          ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _OutcomeRow(
                        text: outcomes[i].text,
                        index: i,
                      ),
                      childCount: outcomes.length,
                    ),
                  ),
                ),
              ],

              // ── Bottom padding for CTA ─────────────────────
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ── Sticky CTA ──────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StickyCta(
              label: ctaLabel,
              isCompleted: isCompleted,
              onTap: isCompleted ? null : () => _handleStart(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final Color heroBg;
  final Color heroAccent;

  const _HeroSection({
    required this.topicWithStatus,
    required this.heroBg,
    required this.heroAccent,
  });

  @override
  Widget build(BuildContext context) {
    final t = topicWithStatus.topic;
    final isInProgress = topicWithStatus.isInProgress;

    return Container(
      color: heroBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: heroAccent),
                ),
              ),
              const SizedBox(height: 20),

              // Emoji icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(t.icon, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                t.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                t.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: heroAccent.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 16),

              // Chips
              Wrap(
                spacing: 8,
                children: [
                  _HeroChip(label: t.level.label, accent: heroAccent),
                  _HeroChip(label: '⭐ ${t.xp} XP', accent: heroAccent),
                  _HeroChip(label: '⏱ ${t.duration}', accent: heroAccent),
                ],
              ),

              // Progress bar if in progress
              if (isInProgress) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: topicWithStatus.progressPercent,
                    backgroundColor: Colors.white.withValues(alpha: 0.4),
                    color: heroAccent,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${topicWithStatus.completedSteps} of ${t.stepCount} steps done',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: heroAccent,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final Color accent;
  const _HeroChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Outcome row ───────────────────────────────────────────────
class _OutcomeRow extends StatelessWidget {
  final String text;
  final int index;
  const _OutcomeRow({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 13, color: AppColors.greenDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 260.ms)
        .slideX(begin: 0.04, end: 0, duration: 260.ms, curve: Curves.easeOut);
  }
}

// ── Sticky CTA ────────────────────────────────────────────────
class _StickyCta extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _StickyCta({
    required this.label,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? context.borderColor : AppColors.green,
            foregroundColor:
                isCompleted ? AppColors.getMutedColor(context) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      isCompleted ? AppColors.getMutedColor(context) : Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
