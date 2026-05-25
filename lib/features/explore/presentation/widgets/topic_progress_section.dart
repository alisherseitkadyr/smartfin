import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/topic_item.dart';

/// In-progress progress bar shown in the topic hero header.
/// Only rendered when the topic status is [TopicStatus.inProgress].
class TopicProgressSection extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final Color accent;

  const TopicProgressSection({
    super.key,
    required this.topicWithStatus,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final completed = topicWithStatus.completedSubtopicIds.length;
    final total = topicWithStatus.topic.stepCount;
    final percent = topicWithStatus.progressPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: accent.withValues(alpha: 0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$completed / $total',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'subtopics completed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}
