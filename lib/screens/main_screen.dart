import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/adaptive_navigation.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'theme_settings_screen.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AdaptiveTabItem(
        icon: Icon(Platform.isIOS ? CupertinoIcons.house : Icons.home_outlined),
        activeIcon: Icon(Platform.isIOS ? CupertinoIcons.house_fill : Icons.home),
        label: 'Home',
        page: const HomeScreen(),
      ),
      AdaptiveTabItem(
        icon: Icon(Platform.isIOS ? CupertinoIcons.chart_bar : Icons.analytics_outlined),
        activeIcon: Icon(Platform.isIOS ? CupertinoIcons.chart_bar_fill : Icons.analytics),
        label: 'Analytics',
        page: const StatisticsScreen(),
      ),
      AdaptiveTabItem(
        icon: Icon(Platform.isIOS ? CupertinoIcons.globe : Icons.public_outlined),
        activeIcon: Icon(Platform.isIOS ? CupertinoIcons.globe : Icons.public),
        label: 'Network',
        page: const Center(child: Text('Network - Coming Soon')),
      ),
      AdaptiveTabItem(
        icon: Icon(Platform.isIOS ? CupertinoIcons.person : Icons.person_outline),
        activeIcon: Icon(Platform.isIOS ? CupertinoIcons.person_fill : Icons.person),
        label: 'Profile',
        page: const ThemeSettingsScreen(),
      ),
    ];

    return AdaptiveTabScaffold(
      tabs: tabs,
      currentIndex: _currentIndex,
      onTabChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}