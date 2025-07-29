import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum PlatformType {
  iOS,
  android,
  web,
  macOS,
  windows,
  linux,
  fuchsia,
}

abstract class PlatformService {
  PlatformType get currentPlatform;
  bool get isIOS;
  bool get isAndroid;
  bool get isMobile;
  bool get isDesktop;
  bool get isWeb;
  bool get isMacOS;
  bool get isWindows;
  bool get isLinux;
  bool get isFuchsia;
  bool get isCupertino;
  bool get isMaterial;
  
  double get defaultBorderRadius;
  double get defaultElevation;
  EdgeInsets get defaultPadding;
  double get defaultIconSize;
  
  IconData getAdaptiveIcon(String iconName);
  Widget buildAdaptiveWidget({
    required Widget Function() material,
    required Widget Function() cupertino,
  });
}

class DefaultPlatformService implements PlatformService {
  static final DefaultPlatformService _instance = DefaultPlatformService._internal();
  
  factory DefaultPlatformService() => _instance;
  
  DefaultPlatformService._internal();
  
  @override
  PlatformType get currentPlatform {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isIOS) return PlatformType.iOS;
    if (Platform.isAndroid) return PlatformType.android;
    if (Platform.isMacOS) return PlatformType.macOS;
    if (Platform.isWindows) return PlatformType.windows;
    if (Platform.isLinux) return PlatformType.linux;
    if (Platform.isFuchsia) return PlatformType.fuchsia;
    return PlatformType.android; // Default fallback
  }
  
  @override
  bool get isIOS => !kIsWeb && Platform.isIOS;
  
  @override
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  @override
  bool get isMobile => isIOS || isAndroid;
  
  @override
  bool get isDesktop => isMacOS || isWindows || isLinux;
  
  @override
  bool get isWeb => kIsWeb;
  
  @override
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  
  @override
  bool get isWindows => !kIsWeb && Platform.isWindows;
  
  @override
  bool get isLinux => !kIsWeb && Platform.isLinux;
  
  @override
  bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
  
  @override
  bool get isCupertino => isIOS || isMacOS;
  
  @override
  bool get isMaterial => !isCupertino;
  
  @override
  double get defaultBorderRadius => isCupertino ? 8.0 : 12.0;
  
  @override
  double get defaultElevation => isCupertino ? 0.0 : 2.0;
  
  @override
  EdgeInsets get defaultPadding => EdgeInsets.symmetric(
    horizontal: isCupertino ? 16.0 : 24.0,
    vertical: isCupertino ? 12.0 : 16.0,
  );
  
  @override
  double get defaultIconSize => isCupertino ? 20.0 : 24.0;
  
  @override
  IconData getAdaptiveIcon(String iconName) {
    // This will be implemented in platform_icons.dart
    throw UnimplementedError('Use PlatformIcons class for icon mapping');
  }
  
  @override
  Widget buildAdaptiveWidget({
    required Widget Function() material,
    required Widget Function() cupertino,
  }) {
    return isCupertino ? cupertino() : material();
  }
}

// Extension for easier access
extension PlatformExtensions on BuildContext {
  PlatformService get platform => DefaultPlatformService();
  
  bool get isIOS => platform.isIOS;
  bool get isAndroid => platform.isAndroid;
  bool get isCupertino => platform.isCupertino;
  bool get isMaterial => platform.isMaterial;
  
  T adaptive<T>({
    required T material,
    required T cupertino,
  }) {
    return platform.isCupertino ? cupertino : material;
  }
  
  Widget adaptiveWidget({
    required Widget Function() material,
    required Widget Function() cupertino,
  }) {
    return platform.buildAdaptiveWidget(
      material: material,
      cupertino: cupertino,
    );
  }
}