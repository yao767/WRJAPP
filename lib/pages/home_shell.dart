import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'about_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'suggestion_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomePage(),
      SuggestionPage(),
      SettingsPage(),
      AboutPage(),
    ];
    final titles = const ['主页面', '建议页面', '设置页面', '关于页面'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AppState>().logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
          )
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '主页面'),
          NavigationDestination(icon: Icon(Icons.tips_and_updates), label: '建议'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
          NavigationDestination(icon: Icon(Icons.info), label: '关于'),
        ],
      ),
    );
  }
}
