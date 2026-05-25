import 'package:flutter/material.dart';

import '../data/car_repository.dart';
import '../data/db_service.dart';
import '../models/car.dart';
import '../models/evaluation.dart';
import '../theme/app_theme.dart';
import 'report_screen.dart';

/// 历史记录页：展示过往评估，点开可重看报告，左滑删除。
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<_HistoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HistoryData> _load() async {
    final records = await DbService.all();
    final cars = await CarRepository.loadCars();
    return _HistoryData(records, {for (final c in cars) c.id: c});
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _openReport(EvaluationRecord record) async {
    final cars = await CarRepository.byIds(record.selectedCarIds);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          report: record.report,
          cars: cars,
          fromHistory: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: SafeArea(
        child: FutureBuilder<_HistoryData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null || data.records.isEmpty) {
              return const _EmptyState();
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: data.records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final record = data.records[i];
                return _HistoryCard(
                  record: record,
                  cars: data.cars,
                  onTap: () => _openReport(record),
                  onDelete: () async {
                    if (record.id != null) {
                      await DbService.delete(record.id!);
                    }
                    _reload();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryData {
  final List<EvaluationRecord> records;
  final Map<String, Car> cars;

  const _HistoryData(this.records, this.cars);
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.cars,
    required this.onTap,
    required this.onDelete,
  });

  final EvaluationRecord record;
  final Map<String, Car> cars;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;

  String _name(String? id) =>
      id == null ? '—' : (cars[id]?.name ?? id);

  String get _dateText {
    final d = record.createdAt;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final candidates = record.selectedCarIds.map(_name).join('、');
    return Dismissible(
      key: ValueKey(record.id ?? record.createdAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dateText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.subtle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.ink,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '推荐',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _name(record.recommendedCarId),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '对比：$candidates',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.subtle,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.line,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 34,
              color: AppTheme.subtle,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无评估记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成一次评估后，报告会自动保存到这里',
            style: TextStyle(fontSize: 13, color: AppTheme.subtle),
          ),
        ],
      ),
    );
  }
}
