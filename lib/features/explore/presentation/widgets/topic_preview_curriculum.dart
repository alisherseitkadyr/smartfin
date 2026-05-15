import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';
import 'subtopic_card.dart';

/// Sliver group: "CURRICULUM" label + list of [SubtopicCard]s.
/// Must be placed directly inside a [CustomScrollView.slivers] list.
class TopicPreviewCurriculum extends StatelessWidget {
  final List<SubtopicItem> subtopics;
  final String? selectedSubtopicId;
  final ValueChanged<String> onSelectSubtopic;
  final int completedSteps;

  const TopicPreviewCurriculum({
    super.key,
    required this.subtopics,
    required this.selectedSubtopicId,
    required this.onSelectSubtopic,
    this.completedSteps = 0,
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
                return SubtopicCard(
                  subtopic: subtopic,
                  index: i,
                  isSelected: selectedSubtopicId == subtopic.id,
                  isDone: i < completedSteps,
                  onTap: () => onSelectSubtopic(subtopic.id),
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
