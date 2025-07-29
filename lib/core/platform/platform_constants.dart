import 'package:flutter/material.dart';
import 'platform_service.dart';

class PlatformConstants {
  static final PlatformService _platform = DefaultPlatformService();
  
  // Border Radius Values
  static double get smallRadius => _platform.isCupertino ? 8.0 : 12.0;
  static double get mediumRadius => _platform.isCupertino ? 10.0 : 16.0;
  static double get largeRadius => _platform.isCupertino ? 14.0 : 20.0;
  static double get extraLargeRadius => _platform.isCupertino ? 28.0 : 28.0;
  
  // Elevation Values
  static double get noElevation => 0.0;
  static double get lowElevation => _platform.isCupertino ? 0.0 : 2.0;
  static double get mediumElevation => _platform.isCupertino ? 0.0 : 4.0;
  static double get highElevation => _platform.isCupertino ? 0.0 : 8.0;
  
  // Padding Values
  static EdgeInsets get smallPadding => EdgeInsets.all(_platform.isCupertino ? 8.0 : 12.0);
  static EdgeInsets get mediumPadding => EdgeInsets.all(_platform.isCupertino ? 12.0 : 16.0);
  static EdgeInsets get largePadding => EdgeInsets.all(_platform.isCupertino ? 16.0 : 24.0);
  
  static EdgeInsets get horizontalPadding => EdgeInsets.symmetric(
    horizontal: _platform.isCupertino ? 16.0 : 24.0,
  );
  
  static EdgeInsets get verticalPadding => EdgeInsets.symmetric(
    vertical: _platform.isCupertino ? 12.0 : 16.0,
  );
  
  static EdgeInsets get defaultButtonPadding => EdgeInsets.symmetric(
    horizontal: _platform.isCupertino ? 16.0 : 24.0,
    vertical: _platform.isCupertino ? 12.0 : 16.0,
  );
  
  // Spacing Values
  static double get tinySpace => 4.0;
  static double get smallSpace => 8.0;
  static double get mediumSpace => 16.0;
  static double get largeSpace => 24.0;
  static double get extraLargeSpace => 32.0;
  
  // Navigation Bar Heights
  static double get navigationBarHeight => _platform.isCupertino ? 56.0 : 80.0;
  static double get navigationBarSpacing => _platform.isCupertino ? 1.0 : 16.0;
  
  // Divider Values
  static double get dividerThickness => _platform.isCupertino ? 0.5 : 1.0;
  static double get dividerIndent => _platform.isCupertino ? 16.0 : 0.0;
  
  // Animation Durations
  static Duration get shortAnimationDuration => const Duration(milliseconds: 200);
  static Duration get mediumAnimationDuration => const Duration(milliseconds: 300);
  static Duration get longAnimationDuration => const Duration(milliseconds: 500);
  
  // App Bar Settings
  static bool get centerTitle => _platform.isCupertino;
  static double get appBarElevation => _platform.isCupertino ? 0.0 : 3.0;
  
  // Icon Sizes
  static double get smallIconSize => _platform.isCupertino ? 18.0 : 20.0;
  static double get mediumIconSize => _platform.isCupertino ? 20.0 : 24.0;
  static double get largeIconSize => _platform.isCupertino ? 24.0 : 28.0;
  
  // Border Radius Helpers
  static BorderRadius get smallBorderRadius => BorderRadius.circular(smallRadius);
  static BorderRadius get mediumBorderRadius => BorderRadius.circular(mediumRadius);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(largeRadius);
  static BorderRadius get extraLargeBorderRadius => BorderRadius.circular(extraLargeRadius);
  
  static BorderRadius get topBorderRadius => BorderRadius.only(
    topLeft: Radius.circular(_platform.isCupertino ? 10.0 : 20.0),
    topRight: Radius.circular(_platform.isCupertino ? 10.0 : 20.0),
  );
  
  // Box Decorations
  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: mediumBorderRadius,
    boxShadow: _platform.isCupertino ? null : [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Text Styles
  static TextStyle? adaptiveTextStyle(BuildContext context, TextStyle? baseStyle) {
    if (_platform.isCupertino) {
      return baseStyle?.copyWith(
        fontWeight: FontWeight.w500,
      );
    }
    return baseStyle;
  }
}

// Extension for easier access
extension PlatformConstantsExtension on BuildContext {
  PlatformConstants get platformConstants => PlatformConstants();
  
  double get smallRadius => PlatformConstants.smallRadius;
  double get mediumRadius => PlatformConstants.mediumRadius;
  double get largeRadius => PlatformConstants.largeRadius;
  
  EdgeInsets get smallPadding => PlatformConstants.smallPadding;
  EdgeInsets get mediumPadding => PlatformConstants.mediumPadding;
  EdgeInsets get largePadding => PlatformConstants.largePadding;
  
  BorderRadius get smallBorderRadius => PlatformConstants.smallBorderRadius;
  BorderRadius get mediumBorderRadius => PlatformConstants.mediumBorderRadius;
  BorderRadius get largeBorderRadius => PlatformConstants.largeBorderRadius;
}