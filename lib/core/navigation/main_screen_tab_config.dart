import 'package:flutter/material.dart';
import 'package:katomik/shared/widgets/adaptive_navigation.dart';
import 'package:katomik/core/platform/platform_icons.dart';
import 'package:katomik/features/home/presentation/screens/home_screen.dart';
import 'package:katomik/features/profile/presentation/screens/profile_screen.dart';
import 'package:katomik/features/community/presentation/screens/discover_communities_screen.dart';
import 'package:katomik/shared/widgets/profile_tab_icon.dart';
import '../../l10n/app_localizations.dart';

class MainScreenTabConfig {
  static List<AdaptiveTabItem> getTabs(BuildContext context) {
    return [
      AdaptiveTabItem(
        icon: Icon(PlatformIcons.home),
        activeIcon: Icon(PlatformIcons.homeActive),
        label: AppLocalizations.of(context).home,
        page: const HomeScreen(),
      ),
      AdaptiveTabItem(
        icon: Icon(PlatformIcons.globe),
        activeIcon: Icon(PlatformIcons.globeActive),
        label: AppLocalizations.of(context).communities,
        page: const DiscoverCommunitiesScreen(),
      ),
      AdaptiveTabItem(
        icon: const ProfileTabIcon(isActive: false),
        activeIcon: const ProfileTabIcon(isActive: true),
        label: AppLocalizations.of(context).profile,
        page: const ProfileScreen(),
      ),
    ];
  }

  static const int homeTabIndex = 0;
  static const int communityTabIndex = 1;
  static const int profileTabIndex = 2;
}