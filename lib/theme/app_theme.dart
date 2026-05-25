import 'package:flutter/material.dart';

/// 极简黑白设计：参考 Apple 的设计语言 —— 留白、克制，大道至简。
class AppTheme {
  static const Color ink = Color(0xFF1D1D1F); // 近黑：主文字、按钮
  static const Color subtle = Color(0xFF86868B); // 次要灰
  static const Color bg = Color(0xFFF5F5F7); // 浅灰背景
  static const Color surface = Color(0xFFFFFFFF); // 白色卡片
  static const Color line = Color(0xFFE5E5EA); // 分隔线

  // 主色即近黑，强调色同样走黑白体系。
  static const Color primary = ink;
  static const Color primaryDark = Color(0xFF000000);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: ink,
      primary: ink,
      brightness: Brightness.light,
    ).copyWith(surface: bg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: ink,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: line,
          disabledForegroundColor: subtle,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: const Color(0xFFEDEDEF),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected) ? ink : subtle,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? ink : subtle,
          ),
        ),
      ),
    );
  }
}
