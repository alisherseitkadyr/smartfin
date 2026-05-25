import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';

class LessonInteractiveView extends StatelessWidget {
  final LessonStep step;

  const LessonInteractiveView({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final content = step.interactiveContent;
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    final kind = step.interactiveType ?? _string(content, 'type');

    if (kind == 'net_worth_calculator') {
      return _NetWorthCalculator(content: content);
    }
    if (kind == 'drag_drop' || content.containsKey('categories')) {
      return _CategorySorter(content: content);
    }
    if (kind == 'input_numbers' ||
        kind == 'input_text' ||
        content.containsKey('fields')) {
      return _InputExercise(content: content, inputType: kind);
    }
    if (_string(content, 'type') == 'scenario_selector' ||
        content.containsKey('scenarios')) {
      return _ScenarioSelector(content: content);
    }
    if (_string(content, 'type') == 'portfolio_choice') {
      return _PortfolioChoice(content: content);
    }
    if (_string(content, 'type') == 'error_detector') {
      return _ErrorDetector(content: content);
    }
    if (kind == 'simulator' ||
        _string(content, 'type') == 'loan_calculator' ||
        content.containsKey('formula')) {
      return _LoanCalculator(content: content);
    }

    return _GenericInteractive(content: content);
  }
}

class _NetWorthCalculator extends StatefulWidget {
  final Map<String, dynamic> content;

  const _NetWorthCalculator({required this.content});

  @override
  State<_NetWorthCalculator> createState() => _NetWorthCalculatorState();
}

class _NetWorthCalculatorState extends State<_NetWorthCalculator> {
  late final List<Map<String, dynamic>> _inputs;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _inputs = _mapList(widget.content['inputs']);
    _controllers = {
      for (final input in _inputs)
        _string(input, 'key'): TextEditingController()
          ..addListener(() => setState(() {})),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = _sumGroup('assets');
    final liabilities = _sumGroup('liabilities');
    final netWorth = assets - liabilities;
    final hasValues = _controllers.values.any((c) => c.text.trim().isNotEmpty);
    final isPositive = netWorth >= 0;
    final verdict = isPositive
        ? _string(widget.content, 'verdict_positive')
        : _string(widget.content, 'verdict_negative');

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          if (_string(widget.content, 'instruction').isNotEmpty)
            const SizedBox(height: AppSpacing.lg),
          _MoneyInputGroup(
            title: 'Assets',
            inputs: _inputs
                .where((input) => _string(input, 'group') == 'assets')
                .toList(),
            controllers: _controllers,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MoneyInputGroup(
            title: 'Liabilities',
            inputs: _inputs
                .where((input) => _string(input, 'group') == 'liabilities')
                .toList(),
            controllers: _controllers,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ResultPanel(
            title: 'Net worth',
            value: _formatMoney(netWorth),
            tone: isPositive ? _PanelTone.positive : _PanelTone.warning,
            detail: hasValues ? verdict : _string(widget.content, 'cta'),
          ),
        ],
      ),
    );
  }

  num _sumGroup(String group) {
    return _inputs
        .where((input) => _string(input, 'group') == group)
        .fold<num>(
          0,
          (sum, input) =>
              sum + _parseNumber(_controllers[_string(input, 'key')]?.text),
        );
  }
}

class _MoneyInputGroup extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> inputs;
  final Map<String, TextEditingController> controllers;

  const _MoneyInputGroup({
    required this.title,
    required this.inputs,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    if (inputs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title),
        const SizedBox(height: AppSpacing.sm),
        ...inputs.map(
          (input) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _InteractiveTextField(
              controller: controllers[_string(input, 'key')]!,
              label: _string(input, 'label'),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
      ],
    );
  }
}

class _InputExercise extends StatefulWidget {
  final Map<String, dynamic> content;
  final String? inputType;

  const _InputExercise({required this.content, required this.inputType});

  @override
  State<_InputExercise> createState() => _InputExerciseState();
}

class _InputExerciseState extends State<_InputExercise> {
  late final List<Map<String, dynamic>> _fields;
  late final Map<String, TextEditingController> _controllers;

  bool get _isTextInput => widget.inputType == 'input_text';

  @override
  void initState() {
    super.initState();
    _fields = _mapList(widget.content['fields']);
    _controllers = {
      for (final field in _fields)
        _string(field, 'id'): TextEditingController()
          ..addListener(() => setState(() {})),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controllers.values.any((c) => c.text.trim().isNotEmpty);
    final validation = _map(widget.content['validation']);
    final example = _map(widget.content['exampleAnswer']);
    final enteredTotal = _controllers.values.fold<num>(
      0,
      (sum, controller) => sum + _parseNumber(controller.text),
    );
    final targetTotal = _number(validation['sumMustEqual']);

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          if (_string(widget.content, 'instruction').isNotEmpty)
            const SizedBox(height: AppSpacing.lg),
          ..._fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _InteractiveTextField(
                controller: _controllers[_string(field, 'id')]!,
                label: _string(field, 'label'),
                keyboardType: _isTextInput
                    ? TextInputType.multiline
                    : TextInputType.number,
                minLines: _isTextInput ? 3 : 1,
                maxLines: _isTextInput ? 4 : 1,
              ),
            ),
          ),
          if (targetTotal != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ResultPanel(
              title: 'Entered total',
              value: _formatMoney(enteredTotal),
              tone: enteredTotal == targetTotal
                  ? _PanelTone.positive
                  : _PanelTone.neutral,
              detail: 'Target: ${_formatMoney(targetTotal)}',
            ),
          ],
          if (hasInput && example.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _AnswerPreview(
              title: 'Example answer',
              values: example,
              explanation: _string(widget.content, 'explanation'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategorySorter extends StatefulWidget {
  final Map<String, dynamic> content;

  const _CategorySorter({required this.content});

  @override
  State<_CategorySorter> createState() => _CategorySorterState();
}

class _CategorySorterState extends State<_CategorySorter> {
  final Map<String, String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final categories = _mapList(widget.content['categories']);
    final items = _mapList(widget.content['items']);
    final answers = {
      for (final answer in _mapList(widget.content['answers']))
        _string(answer, 'itemId'): _string(answer, 'categoryId'),
    };
    final isComplete = items.isNotEmpty && _selected.length == items.length;
    final correctCount = _selected.entries
        .where((entry) => answers[entry.key] == entry.value)
        .length;

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          const SizedBox(height: AppSpacing.lg),
          ...items.map(
            (item) => _ChoiceBlock(
              title: _string(item, 'text'),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: categories.map((category) {
                  final itemId = _string(item, 'id');
                  final categoryId = _string(category, 'id');
                  return _OptionChip(
                    label: _string(category, 'label'),
                    selected: _selected[itemId] == categoryId,
                    onSelected: () {
                      setState(() => _selected[itemId] = categoryId);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: AppSpacing.md),
            _ResultPanel(
              title: 'Result',
              value: '$correctCount / ${items.length}',
              tone: correctCount == items.length
                  ? _PanelTone.positive
                  : _PanelTone.warning,
              detail: _string(widget.content, 'explanation'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScenarioSelector extends StatefulWidget {
  final Map<String, dynamic> content;

  const _ScenarioSelector({required this.content});

  @override
  State<_ScenarioSelector> createState() => _ScenarioSelectorState();
}

class _ScenarioSelectorState extends State<_ScenarioSelector> {
  final Map<int, String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final scenarios = _mapList(widget.content['scenarios']);
    final options = _stringList(widget.content['options']);

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          const SizedBox(height: AppSpacing.lg),
          ...scenarios.asMap().entries.map((entry) {
            final index = entry.key;
            final scenario = entry.value;
            final selected = _selected[index];
            final correct = _string(scenario, 'correct_answer');
            return _ChoiceBlock(
              title: _string(scenario, 'text'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: options
                        .map(
                          (option) => _OptionChip(
                            label: option,
                            selected: selected == option,
                            onSelected: () {
                              setState(() => _selected[index] = option);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  if (selected != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InlineFeedback(
                      correct: selected == correct,
                      text: _string(scenario, 'explanation'),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PortfolioChoice extends StatefulWidget {
  final Map<String, dynamic> content;

  const _PortfolioChoice({required this.content});

  @override
  State<_PortfolioChoice> createState() => _PortfolioChoiceState();
}

class _PortfolioChoiceState extends State<_PortfolioChoice> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final options = _mapList(widget.content['options']);
    final correct = _string(widget.content, 'correct');

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          const SizedBox(height: AppSpacing.lg),
          ...options.map((option) {
            final name = _string(option, 'name');
            return _SelectablePanel(
              selected: _selected == name,
              title: name,
              onTap: () => setState(() => _selected = name),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _stringList(
                  option['data'],
                ).map((item) => _DataPill(text: item)).toList(),
              ),
            );
          }),
          if (_selected != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InlineFeedback(correct: _selected == correct, text: correct),
          ],
        ],
      ),
    );
  }
}

class _ErrorDetector extends StatefulWidget {
  final Map<String, dynamic> content;

  const _ErrorDetector({required this.content});

  @override
  State<_ErrorDetector> createState() => _ErrorDetectorState();
}

class _ErrorDetectorState extends State<_ErrorDetector> {
  final Map<int, String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final cases = _mapList(widget.content['cases']);
    final allDone = cases.isNotEmpty && _selected.length == cases.length;

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          const SizedBox(height: AppSpacing.lg),
          ...cases.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final selected = _selected[index];
            final correct = _string(item, 'correct');
            return _ChoiceBlock(
              title: _string(item, 'text'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._stringList(item['options']).map(
                    (option) => _RadioRow(
                      text: option,
                      selected: selected == option,
                      onTap: () => setState(() => _selected[index] = option),
                    ),
                  ),
                  if (selected != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InlineFeedback(
                      correct: selected.startsWith('$correct)'),
                      text: _string(item, 'explanation'),
                    ),
                  ],
                ],
              ),
            );
          }),
          if (allDone &&
              _string(widget.content, 'final_explanation').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _MutedPanel(
                text: _string(widget.content, 'final_explanation'),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoanCalculator extends StatefulWidget {
  final Map<String, dynamic> content;

  const _LoanCalculator({required this.content});

  @override
  State<_LoanCalculator> createState() => _LoanCalculatorState();
}

class _LoanCalculatorState extends State<_LoanCalculator> {
  late final List<Map<String, dynamic>> _inputs;
  late final Map<String, TextEditingController> _controllers;
  late final List<Map<String, dynamic>> _presets;

  @override
  void initState() {
    super.initState();
    _inputs = _mapList(widget.content['inputs']);
    _presets = _mapList(widget.content['presets']);
    _controllers = {
      for (final input in _inputs)
        _string(input, 'id'): TextEditingController(
          text: _formatInput(_number(input['default'])),
        )..addListener(() => setState(() {})),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, num> _getValues() {
    return {
      'principal': _parseNumber(_controllers['principal']?.text ?? '0'),
      'rate_pct': _parseNumber(_controllers['rate_pct']?.text ?? '0'),
      'term_months': _parseNumber(_controllers['term_months']?.text ?? '0'),
    };
  }

  Map<String, num> _calculateAnnuity(Map<String, num> values) {
    final principal = values['principal'] ?? 0;
    final ratePercent = values['rate_pct'] ?? 0;
    final termMonths = values['term_months'] ?? 0;

    if (principal <= 0 || ratePercent <= 0 || termMonths <= 0) {
      return {
        'monthly_payment': 0,
        'total_payment': 0,
        'total_interest': 0,
        'overpayment_pct': 0,
      };
    }

    final monthlyRate = ratePercent / 100 / 12;
    final term = termMonths.toInt();
    final powerFactor = pow(1 + monthlyRate, term);
    final monthlyPayment = principal *
        (monthlyRate * powerFactor) /
        (powerFactor - 1);
    final totalPayment = monthlyPayment * termMonths;
    final totalInterest = totalPayment - principal;
    final overpaymentPct =
        principal > 0 ? (totalInterest / principal * 100) : 0;

    return {
      'monthly_payment': monthlyPayment,
      'total_payment': totalPayment,
      'total_interest': totalInterest,
      'overpayment_pct': overpaymentPct,
    };
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      for (final entry in preset.entries) {
        if (entry.key != 'label') {
          final controller = _controllers[entry.key];
          if (controller != null) {
            controller.text = _formatInput(_number(entry.value));
          }
        }
      }
    });
  }

  String _formatInput(num? value) {
    if (value == null || value == 0) return '';
    return value.toStringAsFixed(value == value.toInt() ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    final values = _getValues();
    final results = _calculateAnnuity(values);
    final monthlyPayment = results['monthly_payment'] ?? 0;
    final totalInterest = results['total_interest'] ?? 0;
    final overpaymentPct = results['overpayment_pct'] ?? 0;

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionText(text: _string(widget.content, 'instruction')),
          if (_string(widget.content, 'instruction').isNotEmpty)
            const SizedBox(height: AppSpacing.lg),
          ..._inputs.map((input) {
            final id = _string(input, 'id');
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _InteractiveTextField(
                controller: _controllers[id]!,
                label: _string(input, 'label'),
                keyboardType: TextInputType.number,
              ),
            );
          }),
          if (_presets.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _presets
                  .map((preset) => OutlinedButton(
                    onPressed: () => _applyPreset(preset),
                    child: Text(_string(preset, 'label')),
                  ))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _ResultPanel(
            title: 'Monthly Payment',
            value: _formatMoney(monthlyPayment),
            tone: _PanelTone.positive,
            detail: '',
          ),
          const SizedBox(height: AppSpacing.sm),
          _ResultPanel(
            title: 'Total Interest',
            value: _formatMoney(totalInterest),
            tone: _PanelTone.warning,
            detail: 'Overpayment: ${overpaymentPct.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

class _GenericInteractive extends StatelessWidget {
  final Map<String, dynamic> content;

  const _GenericInteractive({required this.content});

  @override
  Widget build(BuildContext context) {
    final textParts = [
      _string(content, 'instruction'),
      _string(content, 'question'),
      _string(content, 'explanation'),
      _string(content, 'final_explanation'),
      _string(content, 'cta'),
    ].where((value) => value.isNotEmpty).toList();

    return _InteractiveShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final part in textParts) ...[
            Text(part, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
          ],
          if (_mapList(content['fields']).isNotEmpty)
            _KeyValueList(
              items: _mapList(content['fields']),
              labelKey: 'label',
            ),
          if (_mapList(content['inputs']).isNotEmpty)
            _KeyValueList(
              items: _mapList(content['inputs']),
              labelKey: 'label',
            ),
          if (_stringList(content['options']).isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _stringList(
                content['options'],
              ).map((option) => _DataPill(text: option)).toList(),
            ),
        ],
      ),
    );
  }
}

class _InteractiveShell extends StatelessWidget {
  final Widget child;

  const _InteractiveShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: AppColors.isDark(context) ? null : AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _InteractiveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;

  const _InteractiveTextField({
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isNumeric = keyboardType == TextInputType.number;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9\s.,-]'))]
          : null,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        suffixText: isNumeric ? '₸' : null,
      ),
    );
  }
}

class _ChoiceBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChoiceBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _SelectablePanel extends StatelessWidget {
  final bool selected;
  final String title;
  final VoidCallback onTap;
  final Widget child;

  const _SelectablePanel({
    required this.selected,
    required this.title,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.green : context.borderColor;
    final background = selected
        ? _tint(context, AppColors.green)
        : context.mutedXLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppColors.green : context.mutedColor,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: selected ? Colors.white : context.text2Color,
        letterSpacing: 0,
      ),
      selectedColor: AppColors.green,
      backgroundColor: context.mutedXLight,
      side: BorderSide(
        color: selected ? AppColors.green : context.borderColor,
        width: 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? _tint(context, AppColors.green)
                : context.mutedXLight,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: selected ? AppColors.green : context.borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.green : context.mutedColor,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineFeedback extends StatelessWidget {
  final bool correct;
  final String text;

  const _InlineFeedback({required this.correct, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.green : AppColors.amber;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _tint(context, color),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.info_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.text2Color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String title;
  final String value;
  final _PanelTone tone;
  final String detail;

  const _ResultPanel({
    required this.title,
    required this.value,
    required this.tone,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _PanelTone.positive => AppColors.green,
      _PanelTone.warning => AppColors.amber,
      _PanelTone.neutral => AppColors.blue,
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _tint(context, color),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: color, letterSpacing: 0.2),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: context.textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              detail,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.text2Color),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerPreview extends StatelessWidget {
  final String title;
  final Map<String, dynamic> values;
  final String explanation;

  const _AnswerPreview({
    required this.title,
    required this.values,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return _MutedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(title),
          const SizedBox(height: AppSpacing.sm),
          ...values.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(explanation, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _MutedPanel extends StatelessWidget {
  final String? text;
  final Widget? child;

  const _MutedPanel({this.text, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.mutedXLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child:
          child ??
          Text(text ?? '', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _KeyValueList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String labelKey;

  const _KeyValueList({required this.items, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _DataPill(text: _string(item, labelKey)),
            ),
          )
          .toList(),
    );
  }
}

class _DataPill extends StatelessWidget {
  final String text;

  const _DataPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.mutedXLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.borderColor),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _InstructionText extends StatelessWidget {
  final String text;

  const _InstructionText({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: context.text2Color, height: 1.55),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        letterSpacing: 0.5,
        color: context.mutedColor,
      ),
    );
  }
}

enum _PanelTone { positive, warning, neutral }

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return {};
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return [];
  return value.map(_map).where((item) => item.isNotEmpty).toList();
}

List<String> _stringList(Object? value) {
  if (value is! List) return [];
  return value.map((item) => item.toString()).toList();
}

String _string(Map<String, dynamic> map, String key) {
  final value = map[key];
  return value is String ? value.trim() : '';
}

num? _number(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

num _parseNumber(String? value) {
  if (value == null) return 0;
  final cleaned = value
      .replaceAll(RegExp(r'[^0-9.,-]'), '')
      .replaceAll(',', '.');
  return num.tryParse(cleaned) ?? 0;
}

String _formatMoney(num value) {
  final rounded = value.round();
  final sign = rounded < 0 ? '-' : '';
  final digits = rounded.abs().toString();
  final groups = <String>[];

  for (var end = digits.length; end > 0; end -= 3) {
    final start = (end - 3).clamp(0, digits.length).toInt();
    groups.insert(0, digits.substring(start, end));
  }

  return '$sign${groups.join(' ')} ₸';
}

Color _tint(BuildContext context, Color color) {
  return color.withValues(alpha: AppColors.isDark(context) ? 0.18 : 0.10);
}
