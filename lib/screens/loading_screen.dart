import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/car_repository.dart';
import '../data/db_service.dart';
import '../models/ai_report.dart';
import '../models/evaluation.dart';
import '../providers/assessment_provider.dart';
import '../services/llm_service.dart';
import '../services/report_engine.dart';
import '../theme/app_theme.dart';
import 'report_screen.dart';

/// 加载页：调用大模型生成报告，失败或未配置 Key 时走本地兜底引擎。
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final start = DateTime.now();
    final provider = context.read<AssessmentProvider>();
    final profile = provider.buildProfile();
    final cars = await CarRepository.byIds(provider.selectedCarIds);

    AiReport report;
    if (LlmService.configured) {
      try {
        report = await LlmService.generateReport(profile, cars);
      } catch (_) {
        report = ReportEngine.buildLocalReport(profile, cars);
      }
    } else {
      report = ReportEngine.buildLocalReport(profile, cars);
    }

    await DbService.insert(
      EvaluationRecord(
        createdAt: DateTime.now(),
        profile: profile,
        selectedCarIds: provider.selectedCarIds,
        report: report,
      ),
    );

    // 保证加载动画至少出现一会儿，避免一闪而过。
    final elapsed = DateTime.now().difference(start);
    const minShown = Duration(milliseconds: 900);
    if (elapsed < minShown) {
      await Future<void>.delayed(minShown - elapsed);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReportScreen(report: report, cars: cars),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '正在生成你的决策报告…',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '结合你的画像与候选车型逐项分析',
                style: TextStyle(fontSize: 13, color: AppTheme.subtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
