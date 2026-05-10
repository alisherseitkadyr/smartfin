import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/progress_provider.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_providers.dart';
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

  Future<void> _handleStart() async {
    final t = widget.topicWithStatus.topic;

    await ref.read(exploreRepositoryProvider).recordTopicStarted(t.id);

    ref.read(progressNotifierProvider.notifier).startTopic(
          ActiveTopic(
            id: t.id,
            title: t.title,
            icon: t.icon,
            level: t.level.label,
            xp: t.xp,
            duration: t.duration,
            completedSteps: 0,
            totalSteps: t.stepCount,
          ),
        );

    ref.invalidate(homeDataProvider);

    if (mounted) context.push('/learn/lesson/$_selectedSubtopicId');
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.topicWithStatus.isCompleted;

    final ctaLabel = isCompleted
        ? 'Completed ✓'
        : widget.topicWithStatus.isInProgress
            ? 'Continue Learning'
            : 'Start Learning';

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
                  selectedSubtopicId: _selectedSubtopicId,
                  onSelectSubtopic: (id) =>
                      setState(() => _selectedSubtopicId = id),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: _selectedSubtopicId != null
                      ? 120
                      : AppSpacing.xxl,
                ),
              ),
            ],
          ),
          if (_selectedSubtopicId != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StickyLearningCta(
                label: ctaLabel,
                isCompleted: isCompleted,
                onTap: isCompleted ? null : _handleStart,
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
