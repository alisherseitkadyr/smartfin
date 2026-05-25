import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final topicAsync = ref.watch(singleTopicProvider(topicId));
    final subtopicsAsync = ref.watch(topicSubtopicsProvider(topicId));

    return topicAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (topic) {
        if (topic == null) {
          return const Scaffold(body: Center(child: Text('Topic not found')));
        }
        return _PreviewBody(
          topicWithStatus: topic,
          subtopics: subtopicsAsync.valueOrNull ?? [],
          categoryColor: categoryColor,
        );
      },
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
    final t = widget.topicWithStatus.topic;

    await ref.read(setCurrentTopicProvider)(t.id);

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
          ),
        );

    ref.invalidate(homeDataProvider);

    if (mounted) {
      // Navigate to /learn/lesson/:topicId/:subtopicId
      context.push('/learn/lesson/${t.id}/$subtopicId');
    }
  }

  void _startFinalQuiz() {
    final topic = widget.topicWithStatus.topic;
    final lesson = LessonTopic(
      topic: topic,
      steps: const [],
      outcomes: const [],
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

  String _ctaLabel() {
    final isCompleted = widget.topicWithStatus.isCompleted;
    if (isCompleted) return 'Completed ✓';

    if (_allSubtopicsDone) return 'Take Final Quiz';

    if (_selectedSubtopicId == null) return 'Start Learning';

    if (_subtopicIsDone(_selectedSubtopicId!)) return 'Review Topic';

    return widget.topicWithStatus.isInProgress ? 'Continue Topic' : 'Start Topic';
  }

  VoidCallback? _ctaAction() {
    final isCompleted = widget.topicWithStatus.isCompleted;
    if (isCompleted) return null;

    if (_allSubtopicsDone) return _startFinalQuiz;

    if (_selectedSubtopicId == null) {
      // Tap without selection → start the first unfinished subtopic.
      final firstUnfinished = widget.subtopics
          .where((s) => !_subtopicIsDone(s.id))
          .firstOrNull;
      if (firstUnfinished == null) return null;
      return () => _startSubtopicLesson(firstUnfinished.id);
    }

    return () => _startSubtopicLesson(_selectedSubtopicId!);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
                    label: _ctaLabel(),
                    isCompleted: isCompleted,
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
