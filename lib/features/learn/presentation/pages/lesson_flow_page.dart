import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/notification_service.dart';
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

/// Entry point for the lesson flow.
///
/// When [subtopicId] is provided the lesson teaches that specific topic
/// (code: subtopic) inside the section (code: topic).  On completion it marks
/// only that topic as done, then pops back to the section preview.
///
/// When [subtopicId] is null it falls back to the old single-subtopic path
/// (first subtopic), primarily for backward-compat with deep-links.
///
/// Route: /learn/lesson/:topicId  OR  /learn/lesson/:topicId/:subtopicId
class LessonFlowPage extends ConsumerWidget {
  final String topicId;
  final String? subtopicId;

  const LessonFlowPage({super.key, required this.topicId, this.subtopicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = subtopicId != null
        ? ref.watch(
            lessonForSubtopicProvider((
              topicId: topicId,
              subtopicId: subtopicId!,
            )),
          )
        : ref.watch(lessonForTopicProvider(topicId));

    return lessonAsync.when(
      loading: () => const _LessonFlowSkeleton(),
      error: (e, _) => _LessonFlowError(error: e.toString()),
      data: (lesson) => _LessonFlowBody(lesson: lesson, subtopicId: subtopicId),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main body
// ─────────────────────────────────────────────────────────────
class _LessonFlowBody extends ConsumerStatefulWidget {
  final LessonTopic lesson;
  final String? subtopicId;

  const _LessonFlowBody({required this.lesson, required this.subtopicId});

  @override
  ConsumerState<_LessonFlowBody> createState() => _LessonFlowBodyState();
}

class _LessonFlowBodyState extends ConsumerState<_LessonFlowBody>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final NotificationService _notificationService;
  int _currentIndex = 0;
  bool _isSavingProgress = false;
  bool _isNavigatingToQuiz = false;

  List<LessonStep> get steps => widget.lesson.steps;
  int get totalSteps => steps.length;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService.instance;
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = _initialStepIndex;
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final t = widget.lesson.topic;
      ref.read(progressNotifierProvider.notifier).startTopic(
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
      unawaited(_notificationService.cancelTopicReminders());
    });
  }

  void _scheduleAppropriateReminder(String trigger) {
    final svc = _notificationService;
    final topicId = widget.lesson.topic.id;
    final subtopicId = widget.subtopicId ?? widget.lesson.subtopicCode;
    if (_isNavigatingToQuiz) {
      debugPrint('LessonFlow [$trigger]: scheduling take-quiz reminder');
      unawaited(svc.scheduleTakeQuiz(topicId: topicId, subtopicId: subtopicId));
    } else if (_currentIndex < totalSteps) {
      debugPrint('LessonFlow [$trigger]: scheduling continue-topic reminder');
      unawaited(svc.scheduleContinueTopic(topicId: topicId, subtopicId: subtopicId));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('LessonFlow lifecycle: $state  quiz=$_isNavigatingToQuiz  step=$_currentIndex/$totalSteps');
    if (state == AppLifecycleState.paused) {
      _scheduleAppropriateReminder('paused');
    } else if (state == AppLifecycleState.resumed) {
      debugPrint('LessonFlow: cancelling reminder on resume');
      unawaited(_notificationService.cancelTopicReminders());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('LessonFlow dispose: quiz=$_isNavigatingToQuiz  step=$_currentIndex/$totalSteps');
    _scheduleAppropriateReminder('dispose');

    ref.invalidate(currentLessonProvider);
    if (widget.subtopicId != null) {
      ref.invalidate(
        lessonForSubtopicProvider((
          topicId: widget.lesson.topic.id,
          subtopicId: widget.subtopicId!,
        )),
      );
    } else {
      ref.invalidate(lessonForTopicProvider(widget.lesson.topic.id));
    }
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

  void _goNext() {
    if (_isSavingProgress) return;
    unawaited(_handleNext());
  }

  Future<void> _handleNext() async {
    if (totalSteps == 0) return;
    _isSavingProgress = true;

    try {
      // Fire storage write in background — don't block the page animation.
      unawaited(ref.read(learnRepositoryProvider).completeStep(
        completedStepId: steps[_currentIndex].id,
        currentStepIndex: _currentIndex + 1,
      ));

      if (_currentIndex < totalSteps - 1) {
        setState(() => _currentIndex++);
        await _pageController.nextPage(
          duration: AppDurations.page,
          curve: Curves.easeInOut,
        );
        ref
            .read(progressNotifierProvider.notifier)
            .updateStep(widget.lesson.topic.id, _currentIndex);
      } else {
        await _startQuiz();
      }
    } finally {
      _isSavingProgress = false;
    }
  }

  Future<void> _startQuiz() async {
    if (!mounted) return;
    _isNavigatingToQuiz = true;
    unawaited(ref.read(notificationServiceProvider).cancelTopicReminders());

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPage(
          lesson: widget.lesson,
          subtopicId: widget.subtopicId,
        ),
      ),
    );

    if (!mounted) return;
    ref.invalidate(curriculumProvider);
    ref.invalidate(homeDataProvider);
  }

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(
        duration: AppDurations.page,
        curve: Curves.easeInOut,
      );
    } else {
      ref.invalidate(curriculumProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 0) {
      return _LessonFlowError(error: 'This topic has no lesson content yet.');
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
                ref.invalidate(curriculumProvider);
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
                itemBuilder: (context, index) => LessonStepView(
                  key: ValueKey('step_$index'),
                  step: steps[index],
                  stepIndex: index,
                ),
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
// Skeleton & error
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
