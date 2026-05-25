import 'package:flutter/material.dart';

import '../models/ai_report.dart';
import '../models/car.dart';
import '../services/report_engine.dart';
import '../theme/app_theme.dart';

/// 决策报告页：渲染一份结构化报告（大模型生成或本地兜底）。
class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.report,
    required this.cars,
    this.fromHistory = false,
  });

  final AiReport report;
  final List<Car> cars;

  /// 从历史记录打开时为 true：显示返回箭头、底部按钮为「返回」。
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final carMap = {for (final c in cars) c.id: c};
    String nameOf(String id) => carMap[id]?.name ?? id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('决策报告'),
        automaticallyImplyLeading: fromHistory,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (!report.aiGenerated) ...[
              const _FallbackBanner(),
              const SizedBox(height: 16),
            ],
            _ConclusionCard(text: report.conclusion),
            const SizedBox(height: 24),
            const _SectionTitle('候选车排序'),
            const SizedBox(height: 10),
            for (var i = 0; i < report.ranking.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RankRow(
                  rank: i,
                  carName: nameOf(report.ranking[i].carId),
                ),
              ),
            const SizedBox(height: 14),
            const _SectionTitle('详细分析'),
            const SizedBox(height: 10),
            for (final verdict in report.ranking)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CarAnalysis(
                  carName: nameOf(verdict.carId),
                  verdict: verdict,
                ),
              ),
            const SizedBox(height: 14),
            const _SectionTitle('最后的建议'),
            const SizedBox(height: 10),
            _AdviceCard(text: report.finalAdvice),
            const SizedBox(height: 20),
            Center(
              child: Text(
                report.aiGenerated
                    ? '本报告由 GLM-4-Flash 生成'
                    : '本报告由本地规则引擎生成',
                style: const TextStyle(fontSize: 11, color: AppTheme.subtle),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: SafeArea(
          top: false,
          child: FilledButton(
            onPressed: () => fromHistory
                ? Navigator.of(context).pop()
                : Navigator.of(context).popUntil((r) => r.isFirst),
            child: Text(fromHistory ? '返回' : '完成'),
          ),
        ),
      ),
    );
  }
}

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFF1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.bolt_outlined, size: 16, color: AppTheme.subtle),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI 暂未启用（未配置 Key 或调用失败），以下为本地规则分析。',
              style: TextStyle(fontSize: 12, color: AppTheme.subtle),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConclusionCard extends StatelessWidget {
  const _ConclusionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.ink, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_objects_outlined,
                  color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                '一句话结论',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.rank, required this.carName});

  final int rank;
  final String carName;

  @override
  Widget build(BuildContext context) {
    final label = ReportEngine.rankLabels[rank.clamp(0, 2)];
    final stars = ReportEngine.rankStars[rank.clamp(0, 2)];
    final isTop = rank == 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop ? AppTheme.ink : AppTheme.line,
          width: isTop ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isTop
                  ? AppTheme.ink
                  : AppTheme.subtle.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isTop ? Colors.white : AppTheme.subtle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              carName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: i < stars ? AppTheme.ink : AppTheme.line,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarAnalysis extends StatelessWidget {
  const _CarAnalysis({required this.carName, required this.verdict});

  final String carName;
  final CarVerdict verdict;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '关于 $carName',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
          if (verdict.headline.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              verdict.headline,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: AppTheme.subtle,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...verdict.pros.map(
            (p) => _Point(
              icon: Icons.check_rounded,
              text: p,
              color: AppTheme.ink,
            ),
          ),
          if (verdict.cons.isNotEmpty) const SizedBox(height: 4),
          ...verdict.cons.map(
            (c) => _Point(
              icon: Icons.priority_high_rounded,
              text: c,
              color: AppTheme.subtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.45, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.ink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.6,
          color: AppTheme.ink,
        ),
      ),
    );
  }
}
