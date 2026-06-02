import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../explore/presentation/providers/explore_providers.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/entities/quiz.dart';
import '../providers/learn_providers.dart';

class LessonCompletePage extends ConsumerWidget {
  final QuizResult quizResult;
  final String completedTopicId;

  /// The subtopic that was just quizzed, if this was a subtopic quiz.
  /// Null when this is the topic-level final quiz.
  final String? completedSubtopicId;

  /// True when [completedSubtopicId] is the last subtopic in its topic.
  /// Drives the primary button label and navigation target.
  final bool isLastSubtopic;

  const LessonCompletePage({
    super.key,
    required this.quizResult,
    required this.completedTopicId,
    this.completedSubtopicId,
    this.isLastSubtopic = false,
  });

  bool get _isPerfect => quizResult.correctAnswers == quizResult.totalQuestions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            _CheckCircle(isPerfect: _isPerfect)
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const SizedBox(height: 28),

            Text(
                  l10n.lessonComplete,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),

            const SizedBox(height: 8),

            Text(
              l10n.correctScore(
                quizResult.correctAnswers,
                quizResult.totalQuestions,
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
            ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

            const SizedBox(height: 28),

            _XpBadge(xp: quizResult.xpForScore)
                .animate()
                .fadeIn(delay: 360.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  delay: 360.ms,
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),

            const Spacer(flex: 3),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _onNextLesson(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastSubtopic ? l10n.completeTopic : l10n.nextLesson,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 520.ms, duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms),

                  const SizedBox(height: 12),

                  SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _onBackToExplore(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            side: BorderSide(
                              color: AppColors.getMutedLightColor(context),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            l10n.backToExplore,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 580.ms, duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNextLesson(BuildContext context, WidgetRef ref) async {
    await ref.read(learnRepositoryProvider).clearSession();
    ref.invalidate(allTopicsProvider);
    ref.invalidate(homeDataProvider);

    if (completedSubtopicId != null) {
      try {
        final subtopics = await ref.read(
          topicSubtopicsProvider(completedTopicId).future,
        );
        final idx = subtopics.indexWhere((s) => s.id == completedSubtopicId);
        if (idx >= 0 && idx + 1 < subtopics.length) {
          // More subtopics in this topic — start the next one.
          final next = subtopics[idx + 1];
          ref.read(activeLearnTopicIdProvider.notifier).state = completedTopicId;
          ref.read(activeLearnSubtopicIdProvider.notifier).state = next.id;
          ref.read(activeLearnSubtopicTitleProvider.notifier).state = next.title;
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          return;
        }
      } catch (_) {}

      // Last subtopic done — send user to topic preview to take the final quiz
      // or review any subtopic.
      ref.read(activeLearnSubtopicIdProvider.notifier).state = null;
      ref.read(activeLearnSubtopicTitleProvider.notifier).state = null;
      if (context.mounted) {
        context.go('/explore/topic/$completedTopicId');
      }
      return;
    }

    // Topic-level final quiz completed — advance to the next topic.
    ref.read(activeLearnSubtopicIdProvider.notifier).state = null;
    ref.read(activeLearnSubtopicTitleProvider.notifier).state = null;
    try {
      final topics = await ref.read(learnRepositoryProvider).getAllTopics();
      final idx = topics.indexWhere((t) => t.topic.id == completedTopicId);
      if (idx >= 0 && idx + 1 < topics.length) {
        ref.read(activeLearnTopicIdProvider.notifier).state =
            topics[idx + 1].topic.id;
      } else {
        ref.invalidate(currentLessonProvider);
      }
    } catch (_) {
      ref.invalidate(currentLessonProvider);
    }
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _onBackToExplore(BuildContext context, WidgetRef ref) async {
    await ref.read(learnRepositoryProvider).clearSession();
    ref.read(activeLearnSubtopicIdProvider.notifier).state = null;
    ref.read(activeLearnSubtopicTitleProvider.notifier).state = null;
    ref.invalidate(currentLessonProvider);
    ref.invalidate(allTopicsProvider);
    ref.invalidate(homeDataProvider);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isPerfect;
  const _CheckCircle({required this.isPerfect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isPerfect ? Icons.star_rounded : Icons.check_rounded,
          color: AppColors.green,
          size: 52,
        ),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.highlightBorder, width: 1.5),
      ),
      child: Text(
        '+$xp XP',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.amberMid,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
