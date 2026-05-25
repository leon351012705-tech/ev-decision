import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/car_repository.dart';
import '../models/car.dart';
import '../providers/assessment_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// 候选车型选择页：从 15 款预置车型中选 2-3 款。
class CarSelectScreen extends StatelessWidget {
  const CarSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AssessmentProvider>();
    final selectedCount = provider.selectedCarIds.length;

    return Scaffold(
      appBar: AppBar(title: const Text('选择候选车型')),
      body: SafeArea(
        child: FutureBuilder<List<Car>>(
          future: CarRepository.loadCars(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('车型数据加载失败：${snapshot.error}'));
            }
            final cars = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                const Text(
                  '挑出你纠结的 2-3 款，AI 会基于你的画像帮你做对比。',
                  style: TextStyle(fontSize: 14, color: AppTheme.subtle),
                ),
                const SizedBox(height: 16),
                for (final segment in CarRepository.segments)
                  ..._buildSegment(context, segment, cars, provider),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        count: selectedCount,
        canContinue: provider.canGenerateReport,
        onContinue: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoadingScreen()),
          );
        },
      ),
    );
  }

  List<Widget> _buildSegment(
    BuildContext context,
    String segment,
    List<Car> cars,
    AssessmentProvider provider,
  ) {
    final group = cars.where((c) => c.segment == segment).toList();
    if (group.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              segment,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
      for (final car in group)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _CarCard(
            car: car,
            selected: provider.isCarSelected(car.id),
            onTap: () {
              final ok = provider.toggleCar(car.id);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('最多选择 3 款车型'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ),
    ];
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({
    required this.car,
    required this.selected,
    required this.onTap,
  });

  final Car car;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            car.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Tag(text: car.brand),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${car.priceRange} · ${car.category}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.subtle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _Spec(icon: Icons.route_rounded, text: '${car.rangeKm} km'),
                        _Spec(
                          icon: Icons.bolt_rounded,
                          text: car.batteryCapacity,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected ? AppTheme.primary : AppTheme.line,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.line),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppTheme.subtle),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.subtle),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppTheme.subtle),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.count,
    required this.canContinue,
    required this.onContinue,
  });

  final int count;
  final bool canContinue;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '已选 $count / ${AssessmentProvider.maxCars}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: canContinue ? onContinue : null,
                child: const Text('生成决策报告'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
