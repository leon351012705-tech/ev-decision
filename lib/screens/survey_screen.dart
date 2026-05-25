import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/survey.dart';
import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// 引导问卷页：单页一焦点，一次一题。
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _step = 0;

  int get _total => kSurveyQuestions.length;
  bool get _isLast => _step == _total - 1;

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = kSurveyQuestions[_step];
    final provider = context.watch<AssessmentProvider>();
    final answered = provider.isAnswered(question);

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户画像'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / _total,
                      minHeight: 6,
                      backgroundColor: AppTheme.line,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '第 ${_step + 1} / $_total 题',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.subtle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                children: [
                  Text(
                    question.title,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      height: 1.35,
                    ),
                  ),
                  if (question.hint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      question.hint!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.subtle,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ..._buildOptions(context, question, provider),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                onPressed: answered ? _next : null,
                child: Text(_isLast ? '生成决策报告' : '下一步'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions(
    BuildContext context,
    SurveyQuestion question,
    AssessmentProvider provider,
  ) {
    final answer = provider.answerFor(question.id);
    return question.options.map((option) {
      final bool selected;
      final bool dimmed;
      if (question.multi) {
        final list = (answer as List?)?.cast<String>() ?? const [];
        selected = list.contains(option);
        dimmed = !selected && list.length >= question.maxSelect;
      } else {
        selected = answer == option;
        dimmed = false;
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OptionTile(
          label: option,
          selected: selected,
          dimmed: dimmed,
          multi: question.multi,
          onTap: () {
            if (question.multi) {
              provider.toggleMulti(
                question.id,
                option,
                question.maxSelect,
              );
            } else {
              provider.setSingle(question.id, option);
            }
          },
        ),
      );
    }).toList();
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.dimmed,
    required this.multi,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool dimmed;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.42 : 1,
      child: Material(
        color: selected
            ? AppTheme.primary.withValues(alpha: 0.10)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.line,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppTheme.primaryDark : AppTheme.ink,
                    ),
                  ),
                ),
                Icon(
                  multi
                      ? (selected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded)
                      : (selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded),
                  color: selected ? AppTheme.primary : AppTheme.subtle,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
