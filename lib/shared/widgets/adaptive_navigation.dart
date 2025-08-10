import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:katomik/features/habit/presentation/screens/habit_detail_screen.dart';
import 'dart:io';
import '../../features/settings/presentation/screens/theme_settings_screen.dart';
import '../../features/habit/presentation/screens/habit_form_screen.dart';
import '../models/habit.dart';

class AdaptiveNavigationHelper {
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool fullscreenDialog = false,
  }) {
    if (Platform.isIOS) {
      return Navigator.push<T>(
        context,
        CupertinoPageRoute<T>(
          builder: (_) => page,
          fullscreenDialog: fullscreenDialog,
        ),
      );
    }

    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    if (Platform.isIOS) {
      return Navigator.pushReplacement<T, TO>(
        context,
        CupertinoPageRoute<T>(builder: (_) => page),
      );
    }

    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute<T>(builder: (_) => page),
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}

class AdaptiveTabScaffold extends StatelessWidget {
  final List<AdaptiveTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const AdaptiveTabScaffold({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: currentIndex,
          onTap: onTabChanged,
          items: tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: tab.icon,
                  activeIcon: tab.activeIcon ?? tab.icon,
                  label: tab.label,
                ),
              )
              .toList(),
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (_) => tabs[index].page,
            onGenerateRoute: (settings) {
              // Handle navigation within tab
              switch (settings.name) {
                case '/theme-settings':
                  return CupertinoPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  );
                case '/add-habit':
                  return CupertinoPageRoute(
                    builder: (context) => const HabitFormScreen(),
                  );
                case '/habit-detail':
                  final habit = settings.arguments as Habit;
                  return CupertinoPageRoute(
                    builder: (context) => HabitDetailScreen(habit: habit),
                  );
                default:
                  return CupertinoPageRoute(builder: (_) => tabs[index].page);
              }
            },
          );
        },
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabChanged,
        destinations: tabs
            .map(
              (tab) => NavigationDestination(
                icon: tab.icon,
                selectedIcon: tab.activeIcon ?? tab.icon,
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class AdaptiveTabItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final Widget page;

  const AdaptiveTabItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.page,
  });
}
