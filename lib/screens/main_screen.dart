import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/adaptive_navigation.dart';
import 'home/home_screen.dart';
import 'statistics_screen.dart';
import 'theme_settings_screen.dart';
import 'add_habit_screen.dart';
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

    if (Platform.isIOS) {
      return Stack(
        children: [
          AdaptiveTabScaffold(
            tabs: tabs,
            currentIndex: _currentIndex,
            onTabChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          if (_currentIndex == 0) // Show FAB only on Home tab
            Positioned(
              bottom: 100,
              right: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 28,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const AddHabitScreen()),
                  );
                },
              ),
            ),
        ],
      );
    }

    return Scaffold(
      body: AdaptiveTabScaffold(
        tabs: tabs,
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 0 // Show FAB only on Home tab
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}