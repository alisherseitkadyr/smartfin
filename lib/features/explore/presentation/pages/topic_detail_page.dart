import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import '../widgets/explore_widgets.dart';

class TopicDetailPage extends StatelessWidget {
  final CategoryWithTopics categoryWithTopics;

  const TopicDetailPage({super.key, required this.categoryWithTopics});

  @override
  Widget build(BuildContext context) {
    final cat = categoryWithTopics;
    final next = cat.nextTopic;
    final ctaLabel = cat.isFullyCompleted
        ? 'Completed ✓'
        : cat.isStarted
            ? 'Continue Learning'
            : 'Start Learning';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero App Bar ────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: _heroColor(cat.category.color),
                foregroundColor: _heroTextColor(cat.category.color),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _HeroSection(categoryWithTopics: cat),
                ),
              ),

              // ── "Curriculum" label ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'CURRICULUM',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          color: AppColors.getMutedColor(context),
                        ),
                  ),
                ),
              ),

              // ── Curriculum list ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final topic = cat.topics[index];
                      final isLast = index == cat.topics.length - 1;
                      return _CurriculumItem(
                        topicWithStatus: topic,
                        index: index,
                        isLast: isLast,
                        onTap: topic.isLocked ? null : () {
                          // Wire to lesson page via router
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${topic.topic.title}…'),
                              backgroundColor: AppColors.greenDark,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: cat.topics.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky CTA ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _StickyCta(
              label: ctaLabel,
              isCompleted: cat.isFullyCompleted,
              onTap: cat.isFullyCompleted
                  ? null
                  : () {
                      if (next != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening ${next.topic.title}…'),
                            backgroundColor: AppColors.greenDark,
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  Color _heroColor(CategoryColor c) {
    switch (c) {
      case CategoryColor.blue:  return AppColors.blueLight;
      case CategoryColor.navy:  return const Color(0xFFEEF2FF);
      case CategoryColor.green: return AppColors.greenLight;
    }
  }

  Color _heroTextColor(CategoryColor c) {
    switch (c) {
      case CategoryColor.blue:  return const Color(0xFF1D4ED8);
      case CategoryColor.navy:  return AppColors.navy;
      case CategoryColor.green: return AppColors.greenDark;
    }
  }
}

// ── Hero section ──────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final CategoryWithTopics categoryWithTopics;
  const _HeroSection({required this.categoryWithTopics});

  @override
  Widget build(BuildContext context) {
    final cat = categoryWithTopics;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    cat.category.icon,
                    style: const TextStyle(fontSize: 34),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                cat.category.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                cat.category.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              // Stats chips
              Wrap(
                spacing: 8,
                children: [
                  _HeroChip(label: '${cat.topics.length} topics'),
                  _HeroChip(label: '⭐ ${cat.totalXp} XP'),
                  _HeroChip(label: '⏱ ${cat.totalDuration}'),
                ],
              ),
              const SizedBox(height: 14),
              // Overall progress bar
              if (cat.isStarted) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: cat.progressPercent,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    color: AppColors.greenDark,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${cat.completedCount} of ${cat.topics.length} completed',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  const _HeroChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// ── Curriculum item (card + connector line) ───────────────────
class _CurriculumItem extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final int index;
  final bool isLast;
  final VoidCallback? onTap;

  const _CurriculumItem({
    required this.topicWithStatus,
    required this.index,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(
          delay: Duration(milliseconds: index * 60),
          duration: 300.ms,
        ),
        SlideEffect(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
          delay: Duration(milliseconds: index * 60),
          duration: 300.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Column(
        children: [
          _CurriculumCard(
            topicWithStatus: topicWithStatus,
            index: index,
            onTap: onTap,
          ),
          if (!isLast)
            // Dashed connector line between cards
            SizedBox(
              height: 24,
              child: Center(
                child: CustomPaint(
                  size: const Size(2, 24),
                  painter: _DashedLinePainter(
                    color: topicWithStatus.isCompleted
                        ? AppColors.greenMid
                        : context.borderColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurriculumCard extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final int index;
  final VoidCallback? onTap;

  const _CurriculumCard({
    required this.topicWithStatus,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = topicWithStatus.topic;
    final isLocked = topicWithStatus.isLocked;
    final isCompleted = topicWithStatus.isCompleted;
    final isInProgress = topicWithStatus.isInProgress;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? Theme.of(context).colorScheme.surface.withOpacity(0.6)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.greenMid
                : isInProgress
                    ? AppColors.green
                    : context.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Opacity(
          opacity: isLocked ? 0.55 : 1.0,
          child: Row(
            children: [
              // Step indicator circle
              _StepIndicator(
                index: index,
                status: topicWithStatus.status,
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      t.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // In-progress bar
                    if (isInProgress) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: topicWithStatus.progressPercent,
                                backgroundColor: context.borderColor,
                                color: AppColors.green,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${topicWithStatus.completedSteps}/${t.stepCount}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: AppColors.greenDark),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Meta chips
                    Wrap(
                      spacing: 6,
                      children: [
                        DurationChip(duration: t.duration),
                        XpChip(xp: t.xp),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right icon
              _CardTrailing(status: topicWithStatus.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int index;
  final TopicStatus status;

  const _StepIndicator({required this.index, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TopicStatus.completed:
        return Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
      case TopicStatus.inProgress:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.green, width: 2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.green,
            size: 18,
          ),
        );
      case TopicStatus.locked:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.borderColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.muted,
            size: 16,
          ),
        );
      case TopicStatus.available:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: context.borderColor, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
    }
  }
}

class _CardTrailing extends StatelessWidget {
  final TopicStatus status;
  const _CardTrailing({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case TopicStatus.completed:
        return const SizedBox.shrink();
      case TopicStatus.locked:
        return const SizedBox.shrink();
      case TopicStatus.inProgress:
        return const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.green,
          size: 16,
        );
      case TopicStatus.available:
        return const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.muted,
          size: 16,
        );
    }
  }
}

// ── Dashed connector painter ──────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

// ── Sticky CTA button ─────────────────────────────────────────
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
            backgroundColor:
                isCompleted ? context.borderColor : AppColors.green,
            foregroundColor: isCompleted ? AppColors.getMutedColor(context) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCompleted ? AppColors.getMutedColor(context) : Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}