import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';

// ─────────────────────────────────────────────────────────────
// Hero banner — gradient top section with start button
// ─────────────────────────────────────────────────────────────
class LearnHeroBanner extends StatelessWidget {
  final LessonTopic lesson;
  final VoidCallback onStart;

  const LearnHeroBanner({
    super.key,
    required this.lesson,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F4C2A), Color(0xFF15803D), Color(0xFF22C55E)],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 20, right: 60,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  _HeroLabel(
                    text: isCompleted ? '✅ Completed' : '📍 Current topic',
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    lesson.topic.title,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 60.ms, duration: 350.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    lesson.topic.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.82),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  const SizedBox(height: 16),

                  // Meta chips
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: [
                      _HeroChip(text: '⏱ ${lesson.topic.duration}'),
                      _HeroChip(text: '⭐ ${lesson.topic.xp} XP'),
                      _HeroChip(text: lesson.topic.level.label),
                      _HeroChip(text: '${lesson.steps.length} steps'),
                    ],
                  ).animate().fadeIn(delay: 140.ms, duration: 300.ms),

                  const SizedBox(height: 18),

                  // Progress bar
                  _ProgressSection(lesson: lesson)
                      .animate().fadeIn(delay: 180.ms, duration: 300.ms),

                  const SizedBox(height: 18),

                  // Start / Continue button
                  _StartButton(lesson: lesson, onTap: onStart)
                      .animate().fadeIn(delay: 220.ms, duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  final String text;
  const _HeroLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.white.withOpacity(0.75),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String text;
  const _HeroChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white, letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final LessonTopic lesson;
  const _ProgressSection({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final completed = lesson.isCompleted
        ? lesson.steps.length
        : lesson.completedSteps;
    final total = lesson.steps.length;
    final pct = total > 0 ? completed / total : 0.0;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.25),
              color: Colors.white,
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$completed / $total steps',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white.withOpacity(0.85),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  final LessonTopic lesson;
  final VoidCallback onTap;
  const _StartButton({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isCompleted
            ? Colors.white.withOpacity(0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.greenLight.withOpacity(0.3),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: isCompleted
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                  color: isCompleted ? Colors.white : AppColors.greenDark,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  lesson.startButtonLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isCompleted ? Colors.white : AppColors.greenDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────
class LearnSectionTitle extends StatelessWidget {
  final String title;
  const LearnSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Steps timeline list
// ─────────────────────────────────────────────────────────────
class StepsList extends StatelessWidget {
  final LessonTopic lesson;
  final ValueChanged<int> onStepTap;

  const StepsList({
    super.key,
    required this.lesson,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final steps = lesson.steps;
    final completedSteps = lesson.isCompleted ? steps.length : lesson.completedSteps;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mutedLight, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          // Step rows
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = i < completedSteps;
            final isCurrent = !lesson.isCompleted && i == completedSteps;
            final isUpcoming = !isDone && !isCurrent;
            final isLast = i == steps.length - 1;

            return _StepRow(
              step: step,
              index: i,
              isDone: isDone,
              isCurrent: isCurrent,
              isUpcoming: isUpcoming,
              isLastStep: isLast,
              showConnector: true,
              onTap: () => onStepTap(i),
            ).animate(delay: Duration(milliseconds: i * 60))
             .fadeIn(duration: 280.ms)
             .slideX(begin: -0.03, end: 0, duration: 280.ms, curve: Curves.easeOut);
          }),

          // Quiz row at end
          const Divider(height: 1),
          _QuizRow(lesson: lesson),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final LessonStep step;
  final int index;
  final bool isDone;
  final bool isCurrent;
  final bool isUpcoming;
  final bool isLastStep;
  final bool showConnector;
  final VoidCallback onTap;

  const _StepRow({
    required this.step,
    required this.index,
    required this.isDone,
    required this.isCurrent,
    required this.isUpcoming,
    required this.isLastStep,
    required this.showConnector,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circle + connector
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  _StepCircle(index: index, isDone: isDone, isCurrent: isCurrent),
                  if (!isLastStep)
                    Container(
                      width: 2, height: 20,
                      color: isDone ? AppColors.greenMid : AppColors.mutedLight,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: Theme.of(context).textTheme.titleMedium),
                  if (isDone || isCurrent) ...[
                    const SizedBox(height: 8),
                    _StepBadge(isDone: isDone, isCurrent: isCurrent),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: isDone ? AppColors.green : AppColors.muted,
              size: isDone ? 20 : 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isCurrent;
  const _StepCircle({required this.index, required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Widget child;

    if (isDone) {
      bg = AppColors.greenLight; fg = AppColors.greenDark;
      child = const Icon(Icons.check, size: 16, color: AppColors.greenDark);
    } else if (isCurrent) {
      bg = AppColors.green; fg = Colors.white;
      child = Text('${index + 1}', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700));
    } else {
      bg = AppColors.mutedXLight; fg = AppColors.muted;
      child = Text('${index + 1}', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700));
    }

    return AnimatedContainer(
      duration: 200.ms,
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: bg, shape: BoxShape.circle,
        boxShadow: isCurrent ? [BoxShadow(color: AppColors.green.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)] : null,
      ),
      child: Center(child: child),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  const _StepBadge({required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return _Badge(text: '✓ Done', bg: AppColors.greenLight, fg: AppColors.greenDark);
    }
    if (isCurrent) {
      return _Badge(text: '▶ In progress', bg: AppColors.amberLight, fg: const Color(0xFF92400E));
    }
    return const SizedBox.shrink();
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
    );
  }
}

class _QuizRow extends StatelessWidget {
  final LessonTopic lesson;
  const _QuizRow({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final isQuizDone = lesson.isCompleted;
    final isQuizAvailable = lesson.completedSteps >= lesson.steps.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isQuizDone
                  ? AppColors.greenLight
                  : isQuizAvailable
                      ? AppColors.green
                      : AppColors.mutedXLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isQuizDone
                  ? const Icon(Icons.check, size: 16, color: AppColors.greenDark)
                  : Text(
                      '?',
                      style: TextStyle(
                        color: isQuizAvailable ? Colors.white : AppColors.muted,
                        fontSize: 14, fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Knowledge check', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                if (isQuizDone)
                  _Badge(text: '✓ Passed', bg: AppColors.greenLight, fg: AppColors.greenDark)
                else
                  _Badge(text: '📝 Quiz', bg: const Color(0xFFEEF2FF), fg: AppColors.navy),
              ],
            ),
          ),
          Icon(
            isQuizDone ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            color: isQuizDone ? AppColors.green : AppColors.muted,
            size: isQuizDone ? 20 : 22,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Outcomes card
// ─────────────────────────────────────────────────────────────
class OutcomesCard extends StatelessWidget {
  final List<LessonOutcome> outcomes;
  const OutcomesCard({super.key, required this.outcomes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mutedLight, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: outcomes.asMap().entries.map((entry) {
          final i = entry.key;
          final outcome = entry.value;
          final isLast = i == outcomes.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.greenLight, shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('✓', style: TextStyle(color: AppColors.greenDark, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(outcome.text, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(duration: 280.ms),
              if (!isLast) const Divider(height: 1, indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Related / Up next horizontal scroll
// ─────────────────────────────────────────────────────────────
class NearbyTopicsRow extends StatelessWidget {
  final List<NearbyTopic> topics;
  final ValueChanged<NearbyTopic> onTap;

  const NearbyTopicsRow({
    super.key,
    required this.topics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return _NearbyTopicCard(nearby: topics[i], onTap: () => onTap(topics[i]))
              .animate(delay: Duration(milliseconds: i * 60))
              .fadeIn(duration: 280.ms)
              .slideX(begin: 0.05, end: 0, duration: 280.ms, curve: Curves.easeOut);
        },
      ),
    );
  }
}

class _NearbyTopicCard extends StatelessWidget {
  final NearbyTopic nearby;
  final VoidCallback onTap;
  const _NearbyTopicCard({required this.nearby, required this.onTap});

  static const _icons = {
    'budgeting': '💰', 'saving': '💾', 'emergency': '🛡️',
    'credit': '📊', 'debt': '🏦', 'investing': '📈', 'retirement': '🏖️',
  };

  @override
  Widget build(BuildContext context) {
    final t = nearby.topic;
    final isLocked = nearby.isLocked;
    final isDone = nearby.isCompleted;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedOpacity(
        duration: 150.ms,
        opacity: isLocked ? 0.55 : 1.0,
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDone ? AppColors.greenMid : AppColors.mutedLight,
              width: 1.5,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_icons[t.id] ?? '📚', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  t.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(height: 1.2, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDone ? '✅ Done' : isLocked ? '🔒 Locked' : '⭐ ${t.xp} XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDone ? AppColors.greenDark : AppColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Skeleton loader while content loads
// ─────────────────────────────────────────────────────────────
class LearnPageSkeleton extends StatelessWidget {
  const LearnPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero skeleton
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a6637), Color(0xFF22C55E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 120, height: 14),
                const SizedBox(height: 16),
                _SkeletonBox(width: double.infinity, height: 80),
                const SizedBox(height: 16),
                _SkeletonBox(width: double.infinity, height: 80),
                const SizedBox(height: 16),
                _SkeletonBox(width: double.infinity, height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: AppColors.mutedLight,
        borderRadius: BorderRadius.circular(8),
      ),
    ).animate(onPlay: (c) => c.repeat())
     .shimmer(duration: 1200.ms, color: AppColors.surface.withOpacity(0.6));
  }
}