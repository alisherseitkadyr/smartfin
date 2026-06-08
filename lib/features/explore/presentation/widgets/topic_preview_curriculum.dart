import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';
import 'subtopic_card.dart';

/// Sliver group: "CURRICULUM" label + list of SubtopicCards.
/// Must be placed directly inside a CustomScrollView.slivers list.
class TopicPreviewCurriculum extends StatelessWidget {
  final List<SubtopicItem> subtopics;
  final String? selectedSubtopicId;
  final ValueChanged<String> onSelectSubtopic;

  /// IDs of subtopics that the user has already completed.
  /// SubtopicCard uses contains() — not a position assumption.
  final Set<String> completedSubtopicIds;

  /// When true the whole topic is done and no subtopic should be locked,
  /// even if [completedSubtopicIds] is incomplete.
  final bool isTopicCompleted;

  const TopicPreviewCurriculum({
    super.key,
    required this.subtopics,
    required this.selectedSubtopicId,
    required this.onSelectSubtopic,
    this.completedSubtopicIds = const {},
    this.isTopicCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Text(
              'CURRICULUM',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.getMutedColor(context),
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final subtopic = subtopics[i];
                final isDone = isTopicCompleted || completedSubtopicIds.contains(subtopic.id);
                final isLocked = !isTopicCompleted &&
                    i > 0 &&
                    !completedSubtopicIds.contains(subtopics[i - 1].id);
                return SubtopicCard(
                  subtopic: subtopic,
                  index: i,
                  isSelected: selectedSubtopicId == subtopic.id,
                  isDone: isDone,
                  isLocked: isLocked,
                  onTap: isLocked ? null : () => onSelectSubtopic(subtopic.id),
                );
              },
              childCount: subtopics.length,
            ),
          ),
        ),
      ],
    );
  }
}
