// smartfin/lib/features/learn/presentation/pages/quiz_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import 'lesson_complete_page.dart';

// ─────────────────────────────────────────────────────────────
// Quiz data model — hardcoded per topic (could move to datasource)
// ─────────────────────────────────────────────────────────────
class _QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

const _quizData = <String, List<_QuizQuestion>>{
  'budgeting': [
    _QuizQuestion(
      question: 'What does the "20" in the 50/30/20 rule represent?',
      options: [
        '20% for entertainment',
        '20% for savings',
        '20% for food',
        '20% for rent',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'Why is tracking spending important?',
      options: [
        'To impress your bank',
        'Small frequent expenses add up silently over time',
        'It\'s required by law',
        'To qualify for a credit card',
      ],
      correctIndex: 1,
    ),
  ],
  'saving': [
    _QuizQuestion(
      question: 'What does "pay yourself first" mean?',
      options: [
        'Spend freely, then save whatever\'s left',
        'Save before you have a chance to spend',
        'Pay all bills before saving',
        'Only save when you earn extra income',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'What advantage does a high-yield savings account offer?',
      options: [
        'No minimum balance',
        'Free debit card',
        'Significantly more interest than a standard account',
        'Faster transfers',
      ],
      correctIndex: 2,
    ),
  ],
  'emergency': [
    _QuizQuestion(
      question: 'What is the standard recommendation for an emergency fund?',
      options: [
        '1 month of expenses',
        '3–6 months of essential living expenses',
        '\$500 minimum',
        '10% of annual salary',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'Why keep your emergency fund in a separate account?',
      options: [
        'It earns more interest',
        'Banks require it',
        'Reduces temptation to spend it on non-emergencies',
        'Easier for tax purposes',
      ],
      correctIndex: 2,
    ),
  ],
  'credit': [
    _QuizQuestion(
      question: 'Which factor has the biggest impact on your credit score?',
      options: [
        'Length of credit history',
        'Payment history',
        'Credit mix',
        'Number of new accounts',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'What is a healthy credit utilization rate?',
      options: [
        'Below 30%',
        'Above 70%',
        'Exactly 50%',
        'It doesn\'t matter',
      ],
      correctIndex: 0,
    ),
  ],
  'debt': [
    _QuizQuestion(
      question: 'What does the debt avalanche method prioritise?',
      options: [
        'Smallest balance first',
        'Oldest debt first',
        'Highest interest rate first',
        'Largest balance first',
      ],
      correctIndex: 2,
    ),
    _QuizQuestion(
      question: 'What psychological benefit does the debt snowball offer?',
      options: [
        'Saves the most interest',
        'Faster first wins build momentum',
        'Improves credit score faster',
        'Reduces minimum payments',
      ],
      correctIndex: 1,
    ),
  ],
  'investing': [
    _QuizQuestion(
      question: 'What does an index fund do?',
      options: [
        'Picks the top 10 stocks each month',
        'Buys tiny pieces of hundreds of companies at once',
        'Only invests in government bonds',
        'Tracks a single company\'s performance',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'What is the recommended maximum fee for index funds?',
      options: [
        'Below 1%',
        'Below 0.1%',
        'Below 5%',
        'Fees don\'t matter',
      ],
      correctIndex: 1,
    ),
  ],
  'retirement': [
    _QuizQuestion(
      question: 'What does the "4% rule" in retirement planning mean?',
      options: [
        'Save 4% of your salary each year',
        'Withdraw 4% of savings annually for 30+ years',
        'Invest 4% in bonds',
        'Retire at age 64',
      ],
      correctIndex: 1,
    ),
    _QuizQuestion(
      question: 'Why should you always contribute enough to get your full employer 401(k) match?',
      options: [
        'It reduces your taxes immediately',
        'It\'s required by your employment contract',
        'It\'s an instant 50–100% return on that money',
        'It improves your credit score',
      ],
      correctIndex: 2,
    ),
  ],
};

// ─────────────────────────────────────────────────────────────
// Quiz page
// ─────────────────────────────────────────────────────────────
class QuizPage extends StatefulWidget {
  final LessonTopic lesson;
  const QuizPage({super.key, required this.lesson});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final List<_QuizQuestion> _questions;
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _questions =
        _quizData[widget.lesson.topic.id] ?? _quizData['budgeting']!;
  }

  _QuizQuestion get _current => _questions[_questionIndex];
  bool get _isLastQuestion => _questionIndex == _questions.length - 1;

  void _onOptionTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _current.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _onContinue() {
    if (_isLastQuestion) {
      // Go to completion screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompletePage(
            lesson: widget.lesson,
            correctCount: _correctCount,
            totalQuestions: _questions.length,
          ),
        ),
      );
    } else {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _QuizTopBar(
              currentQ: _questionIndex + 1,
              totalQ: _questions.length,
              onClose: () => Navigator.of(context).pop(),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: _questionIndex / _questions.length,
                    end: (_questionIndex + 1) / _questions.length,
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    backgroundColor: AppColors.mutedLight,
                    color: AppColors.green,
                    minHeight: 6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Question content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _QuizContent(
                  key: ValueKey(_questionIndex),
                  question: _current,
                  selectedOption: _selectedOption,
                  answered: _answered,
                  onOptionTap: _onOptionTap,
                ),
              ),
            ),

            // Bottom — feedback + continue
            if (_answered)
              _AnswerFeedback(
                isCorrect: _selectedOption == _current.correctIndex,
                correctAnswer: _current.options[_current.correctIndex],
                isLastQuestion: _isLastQuestion,
                onContinue: _onContinue,
              ).animate().slideY(begin: 0.3, end: 0, duration: 320.ms, curve: Curves.easeOut)
               .fadeIn(duration: 280.ms),

            if (!_answered) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _QuizTopBar extends StatelessWidget {
  final int currentQ;
  final int totalQ;
  final VoidCallback onClose;

  const _QuizTopBar({
    required this.currentQ,
    required this.totalQ,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
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
              'Knowledge Check',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            'Q$currentQ / $totalQ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizContent extends StatelessWidget {
  final _QuizQuestion question;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onOptionTap;

  const _QuizContent({
    super.key,
    required this.question,
    required this.selectedOption,
    required this.answered,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              height: 1.35,
            ),
          ).animate().fadeIn(duration: 240.ms),

          const SizedBox(height: 28),

          ...question.options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            return _OptionTile(
              index: i,
              label: opt,
              isSelected: selectedOption == i,
              isCorrect: i == question.correctIndex,
              answered: answered,
              onTap: () => onOptionTap(i),
            )
                .animate(delay: Duration(milliseconds: 60 + i * 50))
                .fadeIn(duration: 260.ms)
                .slideY(begin: 0.05, end: 0, duration: 260.ms, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.onTap,
  });

  static const _letters = ['A', 'B', 'C', 'D'];

  Color _borderColor() {
    if (!answered) return AppColors.mutedLight;
    if (isCorrect) return AppColors.green;
    if (isSelected && !isCorrect) return const Color(0xFFEF4444);
    return AppColors.mutedLight;
  }

  Color _bgColor() {
    if (!answered) return AppColors.surface;
    if (isCorrect) return AppColors.greenLight;
    if (isSelected && !isCorrect) return const Color(0xFFFEE2E2);
    return AppColors.surface;
  }

  Color _letterBg() {
    if (!answered) return AppColors.mutedXLight;
    if (isCorrect) return AppColors.green;
    if (isSelected && !isCorrect) return const Color(0xFFEF4444);
    return AppColors.mutedXLight;
  }

  Color _letterFg() {
    if (!answered) return AppColors.muted;
    if (isCorrect || (isSelected && !isCorrect)) return Colors.white;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor(), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _letterBg(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _letters[index],
                  style: TextStyle(
                    color: _letterFg(),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected || (answered && isCorrect)
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: answered && isCorrect
                      ? AppColors.greenDark
                      : answered && isSelected && !isCorrect
                          ? const Color(0xFFB91C1C)
                          : AppColors.navy,
                ),
              ),
            ),
            if (answered && isCorrect)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 20),
            if (answered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFEF4444), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Feedback bottom sheet shown after answering
// ─────────────────────────────────────────────────────────────
class _AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final bool isLastQuestion;
  final VoidCallback onContinue;

  const _AnswerFeedback({
    required this.isCorrect,
    required this.correctAnswer,
    required this.isLastQuestion,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect ? AppColors.greenLight : const Color(0xFFFEE2E2);
    final fg = isCorrect ? AppColors.greenDark : const Color(0xFFB91C1C);
    final icon = isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final iconColor = isCorrect ? AppColors.green : const Color(0xFFEF4444);
    final headlineText = isCorrect ? 'Correct! 🎉' : 'Not quite';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: isCorrect ? AppColors.greenMid : const Color(0xFFFCA5A5), width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(
                headlineText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Correct answer: $correctAnswer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fg,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? AppColors.green : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isLastQuestion ? 'See results →' : 'Continue →',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}