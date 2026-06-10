import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0; // 0 = welcome, 1 = interests, 2–4 = knowledge Q1–Q3
  bool _forward = true;
  bool _isAdvancing = false;
  bool _isSubmitting = false;
  bool _submitted = false;
  StartHereRecommendation? _recommendation;
  Timer? _autoAdvanceTimer;

  static const _totalSteps = 4;
  static const _transitionDuration = Duration(milliseconds: 280);
  static const _autoAdvanceDelay = Duration(milliseconds: 380);

  void _goNext() {
    if (_isAdvancing || _step >= _totalSteps) return;
    _autoAdvanceTimer?.cancel();
    setState(() {
      _forward = true;
      _isAdvancing = true;
      _step = (_step + 1).clamp(0, _totalSteps);
    });
    Future.delayed(_transitionDuration, () {
      if (!mounted) return;
      setState(() => _isAdvancing = false);
    });
  }

  void _goPrev() {
    if (_isAdvancing || _step <= 1) return;
    _autoAdvanceTimer?.cancel();
    setState(() {
      _forward = false;
      _isAdvancing = true;
      _step = (_step - 1).clamp(0, _totalSteps);
    });
    Future.delayed(_transitionDuration, () {
      if (!mounted) return;
      setState(() => _isAdvancing = false);
    });
  }

  bool _isStepComplete(OnboardingDraft draft) => switch (_step) {
        1 => draft.interests.isNotEmpty,
        2 => draft.q1 != null,
        3 => draft.q2 != null,
        4 => draft.q3 != null,
        _ => true,
      };

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final draft = ref.read(onboardingDraftProvider);
    if (!draft.isReady) return;

    setState(() => _isSubmitting = true);
    try {
      final rec =
          await ref.read(onboardingSubmitProvider.notifier).submit(draft);
      if (!mounted) return;
      ref.read(onboardingDraftProvider.notifier).reset();
      setState(() {
        _submitted = true;
        _recommendation = rec;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);
    final submitState = ref.watch(onboardingSubmitProvider);
    final stepComplete = _isStepComplete(draft);

    if (_submitted) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: _StartHereStep(
              recommendation: _recommendation,
              onStart: () {
                final rec = _recommendation;
                if (rec != null && rec.topicId.isNotEmpty) {
                  context.go('/learn/lesson/${rec.topicId}');
                } else {
                  context.go('/home');
                }
              },
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _step == 0
              ? _WelcomeStep(onStart: _goNext)
                  .animate()
                  .fadeIn(duration: 500.ms)
              : Column(
                  children: [
                    OnboardingHeader(
                      step: _step,
                      totalSteps: _totalSteps,
                      onBack: _step > 1 ? _goPrev : null,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: _transitionDuration,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(_forward ? 0.04 : -0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: _buildStep(draft),
                        ),
                      ),
                    ),
                    if (submitState.hasError)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Text(
                          "Couldn't connect — please try again.",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Show Continue button only for the interests step (multi-select)
                    // and the last knowledge question (triggers POST).
                    if (_step == 1 || _step == _totalSteps)
                      ContinueButton(
                        enabled: stepComplete && !_isAdvancing,
                        isLoading: submitState.isLoading || _isSubmitting,
                        isLastStep: _step == _totalSteps,
                        onTap: stepComplete
                            ? (_step == _totalSteps ? _submit : _goNext)
                            : null,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStep(OnboardingDraft draft) {
    final n = ref.read(onboardingDraftProvider.notifier);

    // Auto-advances after selection for single-select steps that are NOT last.
    void autoAdvance(VoidCallback setter) {
      final sourceStep = _step;
      _autoAdvanceTimer?.cancel();
      setter();
      _autoAdvanceTimer = Timer(_autoAdvanceDelay, () {
        if (mounted && _step == sourceStep) _goNext();
      });
    }

    return switch (_step) {
      1 => _InterestsStep(
          selected: draft.interests,
          onToggle: n.toggleInterest,
        ),
      2 => _KnowledgeQuestion(
          questionNumber: 1,
          question:
              'You put 100,000 ₸ in a deposit at 10% per year and don\'t touch it. After 5 years, you have…',
          options: const [
            _QOption('More than 150,000 ₸', 'more'),
            _QOption('Exactly 150,000 ₸', 'exactly'),
            _QOption('Less than 150,000 ₸', 'less'),
            _QOption('Not sure yet', 'not_sure'),
          ],
          selected: draft.q1,
          onSelect: (v) => autoAdvance(() => n.setQ1(v)),
        ),
      3 => _KnowledgeQuestion(
          questionNumber: 2,
          question:
              'Your deposit earns 12% a year, but prices rise 15% a year. After one year, your money can buy…',
          options: const [
            _QOption('More than before', 'more'),
            _QOption('The same as before', 'same'),
            _QOption('Less than before', 'less'),
            _QOption('Not sure yet', 'not_sure'),
          ],
          selected: draft.q2,
          onSelect: (v) => autoAdvance(() => n.setQ2(v)),
        ),
      4 => _KnowledgeQuestion(
          questionNumber: 3,
          question:
              'Putting all your savings into one company\'s stock is usually ___ than a fund holding many companies.',
          options: const [
            _QOption('Safer', 'safer'),
            _QOption('Riskier', 'riskier'),
            _QOption('The same', 'same'),
            _QOption('Not sure yet', 'not_sure'),
          ],
          selected: draft.q3,
          // Last question: no auto-advance; selection enables the Submit button.
          onSelect: n.setQ3,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── Welcome ───────────────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomeStep({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 36)),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            "Let's find your\nstarting point",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 12),
          Text(
            'About 30 seconds — no wrong answers.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                  height: 1.55,
                ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0, duration: 400.ms),
          const SizedBox(height: 36),
          ...[
            ('📚', 'Matched to you', 'Lessons chosen for your actual level'),
            ('🎯', 'Goal-focused path', 'Start where it matters most'),
            ('⚡', 'Quick setup', 'Just a few taps, then you\'re in'),
          ]
              .asMap()
              .entries
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BenefitRow(
                    emoji: e.value.$1,
                    title: e.value.$2,
                    subtitle: e.value.$3,
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))
                      .slideX(begin: 0.05, end: 0),
                ),
              ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Interests (multi-select) ─────────────────────────────────────────

class _InterestsStep extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _InterestsStep({required this.selected, required this.onToggle});

  static const _interests = [
    ('budgeting', 'Budgeting', '💰'),
    ('savings', 'Savings', '🏦'),
    ('credits_and_debts', 'Credits & Debts', '💳'),
    ('financial_planning', 'Planning', '📊'),
    ('investing', 'Investing', '📈'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'What do you want to learn?',
      subtitle: 'Pick all the areas that interest you.',
      body: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: _interests
            .map(
              (t) => TopicChip(
                value: t.$1,
                label: t.$2,
                emoji: t.$3,
                selected: selected.contains(t.$1),
                onToggle: onToggle,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Steps 2–4: Knowledge questions ───────────────────────────────────────────

class _QOption {
  final String text;
  final String key; // unique per question, used for selection state

  const _QOption(this.text, this.key);
}

class _KnowledgeQuestion extends StatelessWidget {
  final int questionNumber;
  final String question;
  final List<_QOption> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _KnowledgeQuestion({
    required this.questionNumber,
    required this.question,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $questionNumber of 3',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.green,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 24),
          ...options.map(
            (o) => OptionCard(
              value: o.key,
              label: o.text,
              selected: selected == o.key,
              onTap: onSelect,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Start Here ────────────────────────────────────────────────────────────────

class _StartHereStep extends StatelessWidget {
  final StartHereRecommendation? recommendation;
  final VoidCallback onStart;

  const _StartHereStep({
    required this.recommendation,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final rec = recommendation;
    final hasRec = rec != null && rec.topicId.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('✅', style: TextStyle(fontSize: 34)),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0)),
          const SizedBox(height: 24),
          Text(
            "You're all set!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          const SizedBox(height: 10),
          Text(
            hasRec
                ? "We've found the right place for you to start."
                : 'Your personalised learning path is ready.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                  height: 1.55,
                ),
          )
              .animate()
              .fadeIn(delay: 180.ms, duration: 400.ms),
          const SizedBox(height: 32),
          if (hasRec) ...[
            Text(
              'Start here',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.green,
                    letterSpacing: 0.5,
                  ),
            )
                .animate()
                .fadeIn(delay: 260.ms, duration: 350.ms),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rec.sectionTitle != null) ...[
                    Text(
                      rec.sectionTitle!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.muted,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    rec.topicTitle.isNotEmpty ? rec.topicTitle : 'First lesson',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenDark,
                        ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 320.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0),
            const SizedBox(height: 36),
          ] else
            const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start Learning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: hasRec ? 420.ms : 300.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
        ],
      ),
    );
  }
}
