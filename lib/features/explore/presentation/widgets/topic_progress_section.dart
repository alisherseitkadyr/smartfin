import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/topic_item.dart';

/// In-progress bar + step counter shown in the topic hero when a topic
/// has already been started.
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
    final t = topicWithStatus.topic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: topicWithStatus.progressPercent,
            backgroundColor: Colors.white.withValues(alpha: 0.4),
            color: accent,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSpacing.sm - 2),
        Text(
          '${topicWithStatus.completedSteps} of ${t.stepCount} steps done',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accent),
        ),
      ],
    );
  }
}
