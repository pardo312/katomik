import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/platform/platform_service.dart';

class PlatformProvider extends ChangeNotifier {
  final PlatformService _platformService = DefaultPlatformService();
  
  PlatformService get platform => _platformService;
  
  // Convenience getters
  bool get isIOS => _platformService.isIOS;
  bool get isAndroid => _platformService.isAndroid;
  bool get isCupertino => _platformService.isCupertino;
  bool get isMaterial => _platformService.isMaterial;
  bool get isMobile => _platformService.isMobile;
  bool get isDesktop => _platformService.isDesktop;
  bool get isWeb => _platformService.isWeb;
  
  // Platform-specific values
  double get defaultBorderRadius => _platformService.defaultBorderRadius;
  double get defaultElevation => _platformService.defaultElevation;
  EdgeInsets get defaultPadding => _platformService.defaultPadding;
  double get defaultIconSize => _platformService.defaultIconSize;
  
  // Helper methods
  T adaptive<T>({
    required T material,
    required T cupertino,
  }) {
    return isCupertino ? cupertino : material;
  }
  
  Widget buildAdaptiveWidget({
    required Widget Function() material,
    required Widget Function() cupertino,
  }) {
    return _platformService.buildAdaptiveWidget(
      material: material,
      cupertino: cupertino,
    );
  }
}

// Extension for easier access through BuildContext
extension PlatformProviderExtension on BuildContext {
  PlatformProvider get platformProvider {
    return Provider.of<PlatformProvider>(this, listen: false);
  }
  
  PlatformProvider watchPlatformProvider() {
    return Provider.of<PlatformProvider>(this);
  }
}