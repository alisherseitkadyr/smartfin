// smartfin/lib/features/learn/presentation/pages/lesson_complete_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import '../providers/learn_providers.dart';

class LessonCompletePage extends ConsumerWidget {
  final LessonTopic lesson;
  final int correctCount;
  final int totalQuestions;

  const LessonCompletePage({
    super.key,
    required this.lesson,
    required this.correctCount,
    required this.totalQuestions,
  });

  /// Streak is hardcoded at 7 for the prototype.
  /// Replace with a real streak provider when available.
  static const int _streakDays = 7;

  bool get _isPerfect => correctCount == totalQuestions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top spacer — push content to golden ratio midpoint
            const Spacer(flex: 2),

            // ── Check icon ────────────────────────────────────
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

            // ── Headline ──────────────────────────────────────
            Text(
              'Lesson Complete!',
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

            // ── Score sub-label ───────────────────────────────
            Text(
              '$correctCount / $totalQuestions correct',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
            ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

            const SizedBox(height: 28),

            // ── XP badge ──────────────────────────────────────
            _XpBadge(xp: lesson.topic.xp)
                .animate()
                .fadeIn(delay: 360.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  delay: 360.ms,
                  duration: 350.ms,
                  curve: Curves.easeOut,
                ),

            const SizedBox(height: 16),

            // ── Streak banner ─────────────────────────────────
            _StreakBanner(days: _streakDays)
                .animate()
                .fadeIn(delay: 440.ms, duration: 300.ms),

            const Spacer(flex: 3),

            // ── Action buttons ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Primary — next topic
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onNextTopic(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Next Topic →',
                        style: TextStyle(
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

                  // Secondary — back to explore
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _onBackToExplore(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        side: BorderSide(color: AppColors.getMutedLightColor(context), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Back to Explore',
                        style: TextStyle(
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

  // ── Navigation handlers ─────────────────────────────────────

  void _onNextTopic(BuildContext context, WidgetRef ref) {
    // Invalidate current lesson so learn page reloads with updated status
    ref.invalidate(currentLessonProvider);
    // Pop the entire lesson flow back to the main tab navigator.
    // go_router: context.go('/explore') or popUntilRoot depending on your setup.
    // For prototype: pop everything back to the tab bar.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onBackToExplore(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ─────────────────────────────────────────────────────────────
// Check circle widget
// ─────────────────────────────────────────────────────────────
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
            color: AppColors.green.withOpacity(0.25),
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

// ─────────────────────────────────────────────────────────────
// XP badge
// ─────────────────────────────────────────────────────────────
class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
      ),
      child: Text(
        '+$xp XP',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: const Color(0xFFD97706),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Streak banner
// ─────────────────────────────────────────────────────────────
class _StreakBanner extends StatelessWidget {
  final int days;
  const _StreakBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            '$days day streak — keep it up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFEA580C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}