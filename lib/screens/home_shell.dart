import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'history_screen.dart';
import 'home_tab.dart';

/// 应用主框架：底部导航 [首页] [历史] [关于]。
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  int _historyTick = 0;

  void _onSelect(int i) {
    setState(() {
      _index = i;
      // 切到历史 tab 时换 key，强制重新读取数据库。
      if (i == 1) _historyTick++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeTab(),
          HistoryScreen(key: ValueKey(_historyTick)),
          const AboutScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: '历史',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline_rounded),
            selectedIcon: Icon(Icons.info_rounded),
            label: '关于',
          ),
        ],
      ),
    );
  }
}
