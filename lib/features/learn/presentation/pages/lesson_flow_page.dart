// smartfin/lib/features/learn/presentation/pages/lesson_flow_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import '../providers/lesson_flow_providers.dart';
import 'quiz_page.dart';

/// Entry point: pushed by go_router with the topicId.
/// Route: /learn/lesson/:topicId
class LessonFlowPage extends ConsumerWidget {
  final String topicId;
  const LessonFlowPage({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonForTopicProvider(topicId));

    return lessonAsync.when(
      loading: () => const _LessonFlowSkeleton(),
      error: (e, _) => _LessonFlowError(error: e.toString()),
      data: (lesson) => _LessonFlowBody(lesson: lesson),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Main body — manages step index internally
// ─────────────────────────────────────────────────────────────
class _LessonFlowBody extends ConsumerStatefulWidget {
  final LessonTopic lesson;
  const _LessonFlowBody({required this.lesson});

  @override
  ConsumerState<_LessonFlowBody> createState() => _LessonFlowBodyState();
}

class _LessonFlowBodyState extends ConsumerState<_LessonFlowBody>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<LessonStep> get steps => widget.lesson.steps;
  int get totalSteps => steps.length;

  @override
  void initState() {
    super.initState();
    // Resume from where user left off
    final initial = (widget.lesson.completedSteps).clamp(0, totalSteps - 1);
    _currentIndex = initial;
    _pageController = PageController(initialPage: initial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < totalSteps - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      // Last step → go to quiz
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizPage(lesson: widget.lesson),
        ),
      );
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / totalSteps;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────
            _TopBar(
              topicTitle: widget.lesson.topic.title,
              xp: widget.lesson.topic.xp,
              onClose: () => Navigator.of(context).pop(),
            ),

            // ── Progress bar ─────────────────────────────────
            _ProgressBar(progress: progress),

            // ── Step counter ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentIndex + 1} of $totalSteps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),

            // ── Page content ──────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalSteps,
                itemBuilder: (context, index) {
                  return _StepCard(
                    key: ValueKey('step_$index'),
                    step: steps[index],
                    stepIndex: index,
                  );
                },
              ),
            ),

            // ── Bottom navigation ─────────────────────────────
            _BottomNav(
              currentIndex: _currentIndex,
              totalSteps: totalSteps,
              onBack: _goBack,
              onNext: _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String topicTitle;
  final int xp;
  final VoidCallback onClose;

  const _TopBar({
    required this.topicTitle,
    required this.xp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.muted,
            iconSize: 22,
          ),
          Expanded(
            child: Text(
              topicTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$xp XP',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFFD97706),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.mutedLight,
              color: AppColors.green,
              minHeight: 6,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step content card
// ─────────────────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final LessonStep step;
  final int stepIndex;

  const _StepCard({super.key, required this.step, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              height: 1.2,
            ),
          )
              .animate(key: ValueKey('title_$stepIndex'))
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.06, end: 0, duration: 280.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),

          // Body
          Text(
            step.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.65,
              color: const Color(0xFF374151),
            ),
          )
              .animate(key: ValueKey('body_$stepIndex'))
              .fadeIn(delay: 60.ms, duration: 280.ms),

          const SizedBox(height: 24),

          // Example card
          _ExampleCard(text: step.example, stepIndex: stepIndex),

          const SizedBox(height: 16),

          // Tip card
          _TipCard(text: step.tip, stepIndex: stepIndex),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String text;
  final int stepIndex;
  const _ExampleCard({required this.text, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: Color(0xFF3B82F6), width: 3.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📌 Example',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF2563EB),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E3A5F),
              height: 1.55,
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('example_$stepIndex'))
        .fadeIn(delay: 120.ms, duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

class _TipCard extends StatelessWidget {
  final String text;
  final int stepIndex;
  const _TipCard({required this.text, required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✅ Remember this',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.greenDark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.greenDark,
              height: 1.55,
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('tip_$stepIndex'))
        .fadeIn(delay: 180.ms, duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNav({
    required this.currentIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
  });

  bool get isLastStep => currentIndex == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.mutedLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          // Page dots
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSteps, (i) {
                final isActive = i == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.green : AppColors.mutedLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),

          // Next / Finish button
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastStep ? 'Quiz' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(width: 6),
                Icon(
                  isLastStep ? Icons.quiz_rounded : Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Skeleton & error states
// ─────────────────────────────────────────────────────────────
class _LessonFlowSkeleton extends StatelessWidget {
  const _LessonFlowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SkeletonBox(width: double.infinity, height: 6),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 200, height: 28),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: double.infinity, height: 90),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: double.infinity, height: 70),
                  const SizedBox(height: 16),
                  _SkeletonBox(width: double.infinity, height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.mutedLight,
        borderRadius: BorderRadius.circular(8),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: AppColors.surface.withOpacity(0.6));
  }
}

class _LessonFlowError extends StatelessWidget {
  final String error;
  const _LessonFlowError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('Couldn\'t load lesson',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(error,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}