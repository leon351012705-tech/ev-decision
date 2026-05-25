import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 关于页：项目说明、开发者信息。条目默认折叠，点开才看详情。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.electric_car_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '电车决策助手',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '版本 1.0.0',
                    style: TextStyle(fontSize: 13, color: AppTheme.subtle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Material(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: const Column(
                children: [
                  _ExpandableItem(
                    title: '这个 App 做什么',
                    body: '结合你的用车场景、预算和偏好，在候选车型里直接告诉你'
                        '哪一台更适合你 —— 而不只是罗列参数。',
                  ),
                  _ItemDivider(),
                  _ExpandableItem(
                    title: '技术栈',
                    body: 'Flutter · Dart · Provider · SQLite · '
                        '大模型 API（智谱 GLM-4-Flash）。'
                        '以 Vibe Coding 模式（Cursor + Claude Code）开发。',
                  ),
                  _ItemDivider(),
                  _ExpandableItem(
                    title: '开发者',
                    body: 'Leon · AI 产品工程师方向。'
                        '车型数据为 MVP 阶段本地预置。',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(height: 1, thickness: 1, color: AppTheme.line),
    );
  }
}

class _ExpandableItem extends StatefulWidget {
  const _ExpandableItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  State<_ExpandableItem> createState() => _ExpandableItemState();
}

class _ExpandableItemState extends State<_ExpandableItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.subtle,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 17),
            child: Text(
              widget.body,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: AppTheme.subtle,
              ),
            ),
          ),
          crossFadeState:
              _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}
