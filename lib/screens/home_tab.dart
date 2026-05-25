import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import 'survey_screen.dart';

/// 欢迎页 / 首页 tab：Logo + Slogan + 开始评估。
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _startAssessment(BuildContext context) {
    context.read<AssessmentProvider>().reset();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SurveyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ink.withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.electric_car_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                '电车决策助手',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '不止帮你比参数，更告诉你——\n哪一台，真正适合你',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppTheme.subtle,
                ),
              ),
              const Spacer(flex: 3),
              const _FeatureRow(),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () => _startAssessment(context),
                child: const Text('开始评估'),
              ),
              const SizedBox(height: 14),
              const Text(
                '15 款热门车型 · 5 个问题 · AI 个性化报告',
                style: TextStyle(fontSize: 12, color: AppTheme.subtle),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _Feature(icon: Icons.quiz_outlined, label: '5 题画像'),
        _Feature(icon: Icons.compare_arrows_rounded, label: '车型对比'),
        _Feature(icon: Icons.auto_awesome_outlined, label: 'AI 决策报告'),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.primaryDark, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.subtle),
        ),
      ],
    );
  }
}
