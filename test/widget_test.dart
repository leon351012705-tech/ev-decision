import 'package:flutter_test/flutter_test.dart';

import 'package:evdecision/main.dart';

void main() {
  testWidgets('首页加载欢迎内容', (WidgetTester tester) async {
    await tester.pumpWidget(const EvDecisionApp());

    expect(find.text('电车决策助手'), findsWidgets);
    expect(find.text('开始评估'), findsOneWidget);
  });
}
