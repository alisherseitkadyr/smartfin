import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import '../providers/learn_providers.dart';
import '../widgets/learn_widgets.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(currentLessonProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: lessonAsync.when(
        loading: () => const LearnPageSkeleton(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(e.toString(), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentLessonProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (lesson) => _LearnContent(lesson: lesson),
      ),
    );
  }
}

class _LearnContent extends ConsumerWidget {
  final LessonTopic lesson;
  const _LearnContent({required this.lesson});

  void _handleStart(BuildContext context, WidgetRef ref) {
    // Navigation to lesson screen will be handled by go_router.
    // For prototype: show a snack confirming the action.
    final label = lesson.startButtonLabel;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label → ${lesson.topic.title}'),
        backgroundColor: AppColors.greenDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleStepTap(BuildContext context, int stepIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening step ${stepIndex + 1}: ${lesson.steps[stepIndex].title}'),
        backgroundColor: AppColors.navy,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleNearbyTap(BuildContext context, WidgetRef ref, NearbyTopic nearby) {
    // Switch the Learn screen to preview this topic
    ref.read(activeLearnTopicIdProvider.notifier).state = nearby.topic.id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbyTopicsProvider);

    return CustomScrollView(
      slivers: [
        // ── Transparent status-bar area ──────────────────────
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: LearnHeroBanner(
              lesson: lesson,
              onStart: () => _handleStart(context, ref),
            ),
          ),
        ),

        // ── Steps section ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LearnSectionTitle(title: 'Lesson steps'),
                StepsList(
                  lesson: lesson,
                  onStepTap: (i) => _handleStepTap(context, i),
                ),
              ],
            ),
          ),
        ),

        // ── Outcomes section ──────────────────────────────────
        if (lesson.outcomes.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LearnSectionTitle(title: "What you'll learn"),
                  OutcomesCard(outcomes: lesson.outcomes),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
          ),

        // ── Up next section ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LearnSectionTitle(title: 'Up next'),
                ),
                nearbyAsync.when(
                  loading: () => const SizedBox(
                    height: 118,
                    child: Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2)),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (nearby) => NearbyTopicsRow(
                    topics: nearby,
                    onTap: (t) => _handleNearbyTap(context, ref, t),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
        ),

        // ── Bottom padding ────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}