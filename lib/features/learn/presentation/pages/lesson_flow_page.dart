import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/progress_provider.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../../explore/presentation/providers/explore_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/entities/lesson_topic.dart';
import '../providers/learn_providers.dart';
import '../providers/lesson_flow_providers.dart';
import '../widgets/learn_skeleton.dart';
import '../widgets/lesson_navigation_bar.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/lesson_step_view.dart';
import 'quiz_page.dart';

/// Entry point: pushed by go_router with the topicId.
/// Route: /learn/lesson/:topicId
class LessonFlowPage extends ConsumerWidget {
  final String topicId;
  const LessonFlowPage({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonForTopicProvider(topicId));

    return lessonAsync.when(
      loading: () => const _LessonFlowSkeleton(),
      error: (e, _) => _LessonFlowError(error: e.toString()),
      data: (lesson) => _LessonFlowBody(lesson: lesson),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main body — manages step index internally
// ─────────────────────────────────────────────────────────────
class _LessonFlowBody extends ConsumerStatefulWidget {
  final LessonTopic lesson;
  const _LessonFlowBody({required this.lesson});

  @override
  ConsumerState<_LessonFlowBody> createState() => _LessonFlowBodyState();
}

class _LessonFlowBodyState extends ConsumerState<_LessonFlowBody>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<LessonStep> get steps => widget.lesson.steps;
  int get totalSteps => steps.length;

  @override
  void initState() {
    super.initState();
    _currentIndex = _initialStepIndex;
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(learnRepositoryProvider)
            .setCurrentTopic(widget.lesson.topic.id),
      );
      final t = widget.lesson.topic;
      ref
          .read(progressNotifierProvider.notifier)
          .startTopic(
            ActiveTopic(
              id: t.id,
              title: t.title,
              icon: t.icon,
              level: t.level.label,
              xp: t.xp,
              duration: t.duration,
              completedSteps: _currentIndex,
              totalSteps: totalSteps,
            ),
          );
    });
  }

  @override
  void dispose() {
    // Invalidate providers so the learn page and explore page reflect the
    // latest local session progress when the flow page is closed.
    // This also handles the case where context.push returns before the page
    // is actually popped (GoRouter root-navigator timing issue).
    ref.invalidate(currentLessonProvider);
    ref.invalidate(lessonForTopicProvider(widget.lesson.topic.id));
    ref.invalidate(allTopicsProvider);
    _pageController.dispose();
    super.dispose();
  }

  int get _initialStepIndex {
    if (totalSteps <= 0) return 0;
    if (widget.lesson.isCompleted) return 0;
    if (widget.lesson.completedSteps >= totalSteps) return totalSteps - 1;
    if (widget.lesson.completedSteps < 0) return 0;
    return widget.lesson.completedSteps;
  }

  void _invalidateOnExit() {
    ref.invalidate(currentLessonProvider);
    ref.invalidate(lessonForTopicProvider(widget.lesson.topic.id));
    ref.invalidate(allTopicsProvider);
  }

  void _goNext() {
    if (totalSteps == 0) return;

    final completedStepId = steps[_currentIndex].id;
    final completedStepCount = _currentIndex + 1;
    unawaited(
      ref
          .read(learnRepositoryProvider)
          .completeStep(
            completedStepId: completedStepId,
            currentStepIndex: completedStepCount,
          ),
    );

    if (_currentIndex < totalSteps - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: AppDurations.page,
        curve: Curves.easeInOut,
      );
      ref
          .read(progressNotifierProvider.notifier)
          .updateStep(widget.lesson.topic.id, _currentIndex);
    } else {
      final topicId = widget.lesson.topic.id;
      ref.read(progressNotifierProvider.notifier).completeTopic(topicId);
      ref.read(exploreRepositoryProvider).recordTopicCompleted(topicId);
      ref.invalidate(allTopicsProvider);
      ref.invalidate(homeDataProvider);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => QuizPage(lesson: widget.lesson)),
      );
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: AppDurations.page,
        curve: Curves.easeInOut,
      );
    } else {
      _invalidateOnExit();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 0) {
      return _LessonFlowError(error: 'Lesson has no steps yet.');
    }

    final progress = (_currentIndex + 1) / totalSteps;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              topicTitle: widget.lesson.topic.title,
              xp: widget.lesson.topic.xp,
              onClose: () {
                _invalidateOnExit();
                Navigator.of(context).pop();
              },
            ),

            LessonProgressBar(value: progress),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    ref
                        .watch(appL10nProvider)
                        .stepOf(_currentIndex + 1, totalSteps),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSteps,
                itemBuilder: (context, index) {
                  return LessonStepView(
                    key: ValueKey('step_$index'),
                    step: steps[index],
                    stepIndex: index,
                  );
                },
              ),
            ),

            LessonNavigationBar(
              currentIndex: _currentIndex,
              totalSteps: totalSteps,
              onBack: _goBack,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  final String topicTitle;
  final int xp;
  final VoidCallback onClose;

  const _TopBar({
    required this.topicTitle,
    required this.xp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.muted,
            iconSize: 22,
          ),
          Expanded(
            child: Text(
              topicTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.amberLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              l10n.xpLabel(xp),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.amberMid,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Skeleton & error states
// ─────────────────────────────────────────────────────────────
class _LessonFlowSkeleton extends StatelessWidget {
  const _LessonFlowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SkeletonBox(width: double.infinity, height: 6),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 200, height: 28),
                  const SizedBox(height: AppSpacing.lg),
                  SkeletonBox(width: double.infinity, height: 90),
                  const SizedBox(height: AppSpacing.lg),
                  SkeletonBox(width: double.infinity, height: 70),
                  const SizedBox(height: AppSpacing.lg),
                  SkeletonBox(width: double.infinity, height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonFlowError extends ConsumerWidget {
  final String error;
  const _LessonFlowError({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.couldntLoadLesson,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
