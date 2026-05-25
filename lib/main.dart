import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/assessment_provider.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EvDecisionApp());
}

class EvDecisionApp extends StatelessWidget {
  const EvDecisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentProvider(),
      child: MaterialApp(
        title: '电车决策助手',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
