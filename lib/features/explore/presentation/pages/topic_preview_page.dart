import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/providers/progress_provider.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../learn/domain/entities/lesson_topic.dart';
import '../../../learn/presentation/pages/quiz_page.dart';
import '../../../learn/presentation/providers/learn_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import '../providers/explore_providers.dart';
import '../widgets/sticky_learning_cta.dart';
import '../widgets/topic_preview_curriculum.dart';
import '../widgets/topic_preview_header.dart';

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
    // Use pre-filled data from the explore list tap for instant rendering.
    // Falls back to loading via singleTopicProvider for deep links.
    final prefilled = ref.watch(selectedTopicDataProvider);
    final topicAsync = ref.watch(singleTopicProvider(topicId));
    final subtopicsAsync = ref.watch(topicSubtopicsProvider(topicId));

    final topic = topicAsync.valueOrNull ?? prefilled;

    if (topic == null) {
      if (topicAsync.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.green)),
        );
      }
      if (topicAsync.hasError) {
        return Scaffold(body: Center(child: Text('Error: ${topicAsync.error}')));
      }
      return const Scaffold(body: Center(child: Text('Topic not found')));
    }

    return _PreviewBody(
      topicWithStatus: topic,
      subtopics: subtopicsAsync.valueOrNull ?? [],
      categoryColor: categoryColor,
    );
  }
}

class _PreviewBody extends ConsumerStatefulWidget {
  final TopicWithStatus topicWithStatus;
  final List<SubtopicItem> subtopics;
  final CategoryColor? categoryColor;

  const _PreviewBody({
    required this.topicWithStatus,
    required this.subtopics,
    this.categoryColor,
  });

  @override
  ConsumerState<_PreviewBody> createState() => _PreviewBodyState();
}

class _PreviewBodyState extends ConsumerState<_PreviewBody> {
  String? _selectedSubtopicId;
  bool _navigating = false;

  // ── Helpers ───────────────────────────────────────────────

  bool get _allSubtopicsDone {
    if (widget.subtopics.isEmpty) return false;
    return widget.subtopics.every(
      (s) => widget.topicWithStatus.completedSubtopicIds.contains(s.id),
    );
  }

  bool _subtopicIsDone(String subtopicId) =>
      widget.topicWithStatus.completedSubtopicIds.contains(subtopicId);

  // ── Actions ───────────────────────────────────────────────

  Future<void> _startSubtopicLesson(String subtopicId) async {
    if (_navigating) return;
    setState(() => _navigating = true);

    final t = widget.topicWithStatus.topic;
    final subtopic = widget.subtopics.where((s) => s.id == subtopicId).firstOrNull;

    await ref.read(setCurrentTopicProvider)(t.id, subtopicCode: subtopicId);

    ref.read(progressNotifierProvider.notifier).startTopic(
          ActiveTopic(
            id: t.id,
            title: t.title,
            icon: t.icon,
            level: t.level.label,
            xp: t.xp,
            duration: t.duration,
            completedSteps: widget.topicWithStatus.completedSteps,
            totalSteps: t.stepCount,
            subtopicId: subtopicId,
            subtopicTitle: subtopic?.title,
          ),
        );

    ref.read(activeLearnTopicIdProvider.notifier).state = t.id;
    ref.read(activeLearnSubtopicIdProvider.notifier).state = subtopicId;
    ref.read(activeLearnSubtopicTitleProvider.notifier).state = subtopic?.title;

    ref.invalidate(homeDataProvider);

    if (mounted) {
      await context.push('/learn/lesson/${t.id}/$subtopicId');
      if (mounted) setState(() => _navigating = false);
    }
  }

  void _startFinalQuiz() {
    final topic = widget.topicWithStatus.topic;
    final lesson = LessonTopic(
      topic: topic,
      steps: const [],
      completedSteps: 0,
      status: widget.topicWithStatus.status,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPage(lesson: lesson),
      ),
    );
  }

  // ── CTA logic ─────────────────────────────────────────────

  String _ctaLabel(AppL10n l10n) {
    // A selected subtopic always takes priority — review is always allowed.
    if (_selectedSubtopicId != null) {
      if (_subtopicIsDone(_selectedSubtopicId!)) return l10n.reviewLesson;
      return widget.topicWithStatus.isInProgress ? l10n.continueTopic : l10n.startTopic;
    }
    // No subtopic selected — offer the final quiz when all lessons are done.
    if (_allSubtopicsDone) return l10n.takeFinalQuiz;
    return l10n.startLearning;
  }

  VoidCallback? _ctaAction() {
    // A selected subtopic always takes priority — review is always allowed.
    if (_selectedSubtopicId != null) {
      return () => _startSubtopicLesson(_selectedSubtopicId!);
    }
    // No subtopic selected — offer the final quiz when all lessons are done.
    if (_allSubtopicsDone) return _startFinalQuiz;
    // Start the first unfinished subtopic.
    final firstUnfinished = widget.subtopics
        .where((s) => !_subtopicIsDone(s.id))
        .firstOrNull;
    if (firstUnfinished == null) return null;
    return () => _startSubtopicLesson(firstUnfinished.id);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appL10nProvider);
    final isCompleted = widget.topicWithStatus.isCompleted;
    final showCta = _selectedSubtopicId != null || _allSubtopicsDone || isCompleted;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: TopicPreviewHeader(
                  topicWithStatus: widget.topicWithStatus,
                  heroBg: widget.categoryColor.heroBg,
                  heroAccent: widget.categoryColor.heroAccent,
                ),
              ),
              if (widget.subtopics.isNotEmpty)
                TopicPreviewCurriculum(
                  subtopics: widget.subtopics,
                  completedSubtopicIds:
                      widget.topicWithStatus.completedSubtopicIds,
                  selectedSubtopicId: _selectedSubtopicId,
                  onSelectSubtopic: (id) =>
                      setState(() => _selectedSubtopicId = id),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: showCta ? 120 : AppSpacing.xxl,
                ),
              ),
            ],
          ),
          if (showCta)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StickyLearningCta(
                    label: _ctaLabel(l10n),
                    onTap: _ctaAction(),
                  )
                  .animate()
                  .moveY(
                    begin: 100,
                    end: 0,
                    duration: AppDurations.cta,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(),
            ),
        ],
      ),
    );
  }
}
