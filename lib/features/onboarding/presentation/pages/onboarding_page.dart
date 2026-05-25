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
  int _step = 0; // 0 = welcome, 1–6 = form steps
  bool _forward = true;
  bool _isAdvancing = false;
  bool _isSubmitting = false;
  Timer? _autoAdvanceTimer;
  static const _totalSteps = 6;
  static const _transitionDuration = Duration(milliseconds: 280);
  static const _autoAdvanceDelay = Duration(milliseconds: 320);

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
    1 => draft.preferredLanguage != null,
    2 => draft.financialLiteracyLevel != null,
    3 => draft.practicalExperience != null,
    4 => draft.learningGoal != null,
    5 => draft.timeCommitment != null,
    6 => draft.preferredTopics.isNotEmpty,
    _ => true,
  };

  Future<void> _submit() async {
    if (_isSubmitting || ref.read(onboardingSubmitProvider).isLoading) return;

    final draft = ref.read(onboardingDraftProvider);
    if (!draft.isReady) return;

    setState(() => _isSubmitting = true);
    try {
      final ok = await ref
          .read(onboardingSubmitProvider.notifier)
          .submit(draft);
      if (ok && mounted) {
        ref.read(onboardingDraftProvider.notifier).reset();
        context.go('/home');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _step == 0
              ? _WelcomeStep(
                  onStart: _goNext,
                ).animate().fadeIn(duration: 500.ms)
              : Column(
                  children: [
                    OnboardingHeader(
                      step: _step,
                      totalSteps: _totalSteps,
                      onBack: _step > 1 ? _goPrev : null,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
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
                          'Failed to save. Please try again.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
    void autoAdvance(VoidCallback setter) {
      final sourceStep = _step;
      _autoAdvanceTimer?.cancel();
      setter();
      _autoAdvanceTimer = Timer(_autoAdvanceDelay, () {
        if (mounted && _step == sourceStep) {
          _goNext();
        }
      });
    }

    return switch (_step) {
      1 => _LanguageStep(
        selected: draft.preferredLanguage,
        onSelect: (v) => autoAdvance(() => n.setLanguage(v)),
      ),
      2 => _LevelStep(
        selected: draft.financialLiteracyLevel,
        onSelect: (v) => autoAdvance(() => n.setLevel(v)),
      ),
      3 => _ExperienceStep(
        selected: draft.practicalExperience,
        onSelect: (v) => autoAdvance(() => n.setExperience(v)),
      ),
      4 => _GoalStep(
        selected: draft.learningGoal,
        onSelect: (v) => autoAdvance(() => n.setGoal(v)),
      ),
      5 => _TimeStep(
        selected: draft.timeCommitment,
        onSelect: (v) => autoAdvance(() => n.setTimeCommitment(v)),
      ),
      6 => _TopicsStep(
        selected: draft.preferredTopics,
        onToggle: n.toggleTopic,
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
                "Let's personalize\nyour experience",
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
                'Answer a few quick questions so we can recommend the best learning path for you.',
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
            ('📚', 'Tailored content', 'Lessons matched to your level'),
            ('🎯', 'Goal-focused path', 'Learn what matters to your goals'),
            ('⏱️', 'Quick setup', 'Only 6 questions, under 2 minutes'),
          ].asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:
                  _BenefitRow(
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Language ──────────────────────────────────────────────────────────

class _LanguageStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _LanguageStep({this.selected, required this.onSelect});

  static const _options = [
    ('kk', 'Қазақша', 'Kazakh', '🇰🇿'),
    ('ru', 'Русский', 'Russian', '🇷🇺'),
    ('en', 'English', 'English', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Preferred language',
      subtitle: 'Choose the language you want to learn in.',
      body: Column(
        children: _options
            .map(
              (o) => OptionCard(
                value: o.$1,
                label: '${o.$4}  ${o.$2}',
                subtitle: o.$3,
                selected: selected == o.$1,
                onTap: onSelect,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Step 2: Knowledge level ───────────────────────────────────────────────────

class _LevelStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _LevelStep({this.selected, required this.onSelect});

  static const _options = [
    ('beginner', 'Beginner', "I'm new to personal finance", '🌱'),
    ('basic', 'Basic', 'I know a few key concepts', '📖'),
    ('intermediate', 'Intermediate', 'I understand most topics', '📈'),
    ('advanced', 'Advanced', 'I actively manage my finances', '🚀'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Financial knowledge',
      subtitle: 'How would you rate your current understanding of finance?',
      body: Column(
        children: _options
            .map(
              (o) => OptionCard(
                value: o.$1,
                label: o.$2,
                subtitle: o.$3,
                emoji: o.$4,
                selected: selected == o.$1,
                onTap: onSelect,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Step 3: Practical experience ─────────────────────────────────────────────

class _ExperienceStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _ExperienceStep({this.selected, required this.onSelect});

  static const _options = [
    ('no_experience', 'No experience', "I don't track my finances yet", '🤷'),
    (
      'tracks_expenses',
      'Tracks expenses',
      'I keep an eye on my spending',
      '📋',
    ),
    (
      'plans_budget',
      'Plans budget',
      'I create and follow monthly budgets',
      '📊',
    ),
    (
      'manages_finances',
      'Manages finances',
      'I actively manage savings & investments',
      '💼',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Your experience',
      subtitle: 'What best describes your current financial habits?',
      body: Column(
        children: _options
            .map(
              (o) => OptionCard(
                value: o.$1,
                label: o.$2,
                subtitle: o.$3,
                emoji: o.$4,
                selected: selected == o.$1,
                onTap: onSelect,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Step 4: Learning goal ─────────────────────────────────────────────────────

class _GoalStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _GoalStep({this.selected, required this.onSelect});

  static const _options = [
    ('general_improvement', 'General improvement', '📚'),
    ('saving_money', 'Save money', '💰'),
    ('debt_management', 'Pay off debt', '💳'),
    ('financial_planning', 'Plan my finances', '🗓️'),
    ('control_spending', 'Control spending', '🛑'),
    ('start_investing', 'Start investing', '📈'),
    ('increase_income', 'Increase income', '💹'),
    ('understand_banking', 'Understand banking', '🏦'),
    ('other', 'Other', '✨'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Main goal',
      subtitle: "What's your primary financial goal right now?",
      body: Column(
        children: _options
            .map(
              (o) => OptionCard(
                value: o.$1,
                label: o.$2,
                emoji: o.$3,
                selected: selected == o.$1,
                onTap: onSelect,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Step 5: Time commitment ───────────────────────────────────────────────────

class _TimeStep extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _TimeStep({this.selected, required this.onSelect});

  static const _options = [
    ('5_min', '5 minutes', 'Quick daily habit', '⚡'),
    ('10_min', '10 minutes', 'Steady progress', '🌿'),
    ('15_min', '15 minutes', 'Solid learning sessions', '🔥'),
    ('20_plus_min', '20+ minutes', 'Deep dive every day', '🚀'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Daily time',
      subtitle: 'How much time can you dedicate to learning each day?',
      body: Column(
        children: _options
            .map(
              (o) => OptionCard(
                value: o.$1,
                label: o.$2,
                subtitle: o.$3,
                emoji: o.$4,
                selected: selected == o.$1,
                onTap: onSelect,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Step 6: Topics (multi-select) ─────────────────────────────────────────────

class _TopicsStep extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _TopicsStep({required this.selected, required this.onToggle});

  static const _topics = [
    ('budgeting', 'Budgeting', '💰'),
    ('savings', 'Savings', '🏦'),
    ('credits_and_debts', 'Credits & Debts', '💳'),
    ('financial_planning', 'Planning', '📊'),
    ('investing', 'Investing', '📈'),
  ];

  @override
  Widget build(BuildContext context) {
    return StepContent(
      title: 'Topics of interest',
      subtitle: 'Select all the topics you want to learn about.',
      body: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: _topics
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
