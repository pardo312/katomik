import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:katomik/shared/widgets/adaptive_navigation.dart';
import 'package:katomik/core/platform/platform_icons.dart';
import 'package:katomik/core/platform/platform_service.dart';
import 'package:katomik/features/home/screens/home_screen.dart';
import 'package:katomik/features/statistics/screens/statistics_screen.dart';
import 'package:katomik/features/profile/screens/profile_screen.dart';
import 'package:katomik/features/habit/screens/add_habit_screen.dart';
import 'package:katomik/providers/navigation_provider.dart';

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
        icon: Icon(PlatformIcons.home),
        activeIcon: Icon(PlatformIcons.homeActive),
        label: 'Home',
        page: const HomeScreen(),
      ),
      AdaptiveTabItem(
        icon: Icon(PlatformIcons.analytics),
        activeIcon: Icon(PlatformIcons.analyticsActive),
        label: 'Analytics',
        page: const StatisticsScreen(),
      ),
      AdaptiveTabItem(
        icon: Icon(PlatformIcons.globe),
        activeIcon: Icon(PlatformIcons.globeActive),
        label: 'Network',
        page: const Center(child: Text('Network - Coming Soon')),
      ),
      AdaptiveTabItem(
        icon: Icon(PlatformIcons.person),
        activeIcon: Icon(PlatformIcons.personActive),
        label: 'Profile',
        page: const ProfileScreen(),
      ),
    ];

    if (context.platform.isIOS) {
      return Consumer<NavigationProvider>(
        builder: (context, navProvider, child) {
          return Stack(
            children: [
              AdaptiveTabScaffold(
                tabs: tabs,
                currentIndex: _currentIndex,
                onTabChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  if (index == 0) {
                    navProvider.showHomeFabIfNeeded();
                  }
                },
              ),
              if (_currentIndex == 0 && navProvider.showHomeFab)
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
        },
      );
    }

    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: AdaptiveTabScaffold(
            tabs: tabs,
            currentIndex: _currentIndex,
            onTabChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index == 0) {
                navProvider.showHomeFabIfNeeded();
              }
            },
          ),
          floatingActionButton: _currentIndex == 0 && navProvider.showHomeFab
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
      },
    );
  }
}