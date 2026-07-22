import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'generate_screen.dart';
import 'history_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final Set<int> _visited = {0};
  final _historyKey = GlobalKey<HistoryScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _visited.contains(0) ? const GenerateScreen() : const SizedBox.shrink(),
          _visited.contains(1) ? ScanScreen(active: _index == 1) : const SizedBox.shrink(),
          _visited.contains(2) ? HistoryScreen(key: _historyKey) : const SizedBox.shrink(),
          _visited.contains(3) ? const SettingsScreen() : const SizedBox.shrink(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) {
          setState(() {
            _index = i;
            _visited.add(i);
          });
          // هر بار که وارد تب تاریخچه می‌شویم، لیست را تازه می‌کنیم چون ممکن است
          // موارد جدیدی از صفحه ساخت/اسکن اضافه شده باشند.
          if (i == 2) {
            _historyKey.currentState?.reload();
          }
        },
        items: const [
          NavItem(icon: Icons.qr_code_2_outlined, activeIcon: Icons.qr_code_2_rounded, label: 'ساخت'),
          NavItem(icon: Icons.qr_code_scanner_outlined, activeIcon: Icons.qr_code_scanner_rounded, label: 'اسکن'),
          NavItem(icon: Icons.history_outlined, activeIcon: Icons.history_rounded, label: 'تاریخچه'),
          NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'تنظیمات'),
        ],
      ),
    );
  }
}
