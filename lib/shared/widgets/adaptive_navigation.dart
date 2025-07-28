import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

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
          items: tabs.map((tab) => BottomNavigationBarItem(
            icon: tab.icon,
            activeIcon: tab.activeIcon ?? tab.icon,
            label: tab.label,
          )).toList(),
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (_) => tabs[index].page,
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
        destinations: tabs.map((tab) => NavigationDestination(
          icon: tab.icon,
          selectedIcon: tab.activeIcon ?? tab.icon,
          label: tab.label,
        )).toList(),
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