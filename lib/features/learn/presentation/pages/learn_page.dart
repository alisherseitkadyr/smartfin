import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import '../providers/learn_providers.dart';
import '../providers/lesson_flow_providers.dart';
import '../widgets/learn_skeleton.dart';
import '../widgets/learn_widgets.dart';
import '../widgets/lesson_hero_banner.dart';
import '../widgets/nearby_topics_row.dart';

class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final lessonAsync = ref.watch(currentLessonProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                Text(
                  l10n.somethingWentWrong,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentLessonProvider),
                  child: Text(l10n.retry),
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

class _LearnContent extends ConsumerStatefulWidget {
  final LessonTopic lesson;
  const _LearnContent({required this.lesson});

  @override
  ConsumerState<_LearnContent> createState() => _LearnContentState();
}

class _LearnContentState extends ConsumerState<_LearnContent> {
  bool _isStarting = false;

  Future<void> _handleStart() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);
    try {
      await ref.read(setCurrentTopicProvider)(widget.lesson.topic.id);
      if (!mounted) return;
      ref.read(activeLearnTopicIdProvider.notifier).state = null;
      ref.invalidate(lessonForTopicProvider(widget.lesson.topic.id));
      final subtopicCode = widget.lesson.subtopicCode;
      final path = subtopicCode != null
          ? '/learn/lesson/${widget.lesson.topic.id}/$subtopicCode'
          : '/learn/lesson/${widget.lesson.topic.id}';
      await context.push(path);
      if (mounted) ref.invalidate(currentLessonProvider);
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _handleNearbyTap(NearbyTopic nearby) {
    ref.read(activeLearnTopicIdProvider.notifier).state = nearby.topic.id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appL10nProvider);
    final nearbyAsync = ref.watch(nearbyTopicsProvider);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: LearnHeroBanner(lesson: widget.lesson),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LearnSectionTitle(title: l10n.lessonSteps),
                      StepsList(lesson: widget.lesson),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LearnSectionTitle(title: l10n.upNext),
                      ),
                      nearbyAsync.when(
                        loading: () => const SizedBox(
                          height: 118,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.green,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (nearby) => NearbyTopicsRow(
                          topics: nearby,
                          onTap: _handleNearbyTap,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
              ),
            ],
          ),
        ),

        LearnStickyStartButton(
          lesson: widget.lesson,
          onTap: _isStarting ? null : _handleStart,
        ).animate().fadeIn(delay: 220.ms, duration: 300.ms).slideY(begin: 0.15, end: 0),
      ],
    );
  }
}
