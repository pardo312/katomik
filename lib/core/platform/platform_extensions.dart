import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'platform_service.dart';
import 'platform_icons.dart';
import 'platform_constants.dart';

// Widget Extensions
extension AdaptiveWidgetExtensions on Widget {
  Widget adaptivePadding(BuildContext context) {
    return Padding(
      padding: context.platform.isCupertino 
          ? PlatformConstants.smallPadding 
          : PlatformConstants.mediumPadding,
      child: this,
    );
  }
  
  Widget adaptiveCard(BuildContext context) {
    final platform = context.platform;
    
    if (platform.isCupertino) {
      return Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: PlatformConstants.mediumBorderRadius,
          boxShadow: null,
        ),
        child: this,
      );
    }
    
    return Card(
      elevation: PlatformConstants.lowElevation,
      shape: RoundedRectangleBorder(
        borderRadius: PlatformConstants.mediumBorderRadius,
      ),
      child: this,
    );
  }
}

// Navigation Extensions
extension NavigationExtensions on BuildContext {
  Future<T?> adaptivePush<T>({
    required Widget page,
    bool fullscreenDialog = false,
  }) {
    if (platform.isCupertino) {
      return Navigator.of(this).push<T>(
        CupertinoPageRoute<T>(
          builder: (_) => page,
          fullscreenDialog: fullscreenDialog,
        ),
      );
    }
    
    return Navigator.of(this).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }
  
  void adaptivePop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}

// Theme Extensions
extension ThemeExtensions on BuildContext {
  Color get adaptivePrimaryColor {
    if (platform.isCupertino) {
      return CupertinoTheme.of(this).primaryColor;
    }
    return Theme.of(this).colorScheme.primary;
  }
  
  Color get adaptiveBackgroundColor {
    if (platform.isCupertino) {
      return CupertinoColors.systemBackground.resolveFrom(this);
    }
    return Theme.of(this).colorScheme.surface;
  }
  
  Color get adaptiveErrorColor {
    if (platform.isCupertino) {
      return CupertinoColors.destructiveRed;
    }
    return Theme.of(this).colorScheme.error;
  }
  
  TextStyle? get adaptiveBodyTextStyle {
    if (platform.isCupertino) {
      return CupertinoTheme.of(this).textTheme.textStyle;
    }
    return Theme.of(this).textTheme.bodyLarge;
  }
  
  TextStyle? get adaptiveHeadlineTextStyle {
    if (platform.isCupertino) {
      return CupertinoTheme.of(this).textTheme.navLargeTitleTextStyle;
    }
    return Theme.of(this).textTheme.headlineMedium;
  }
}

// Loading Indicator Extension
extension LoadingExtensions on BuildContext {
  Widget get adaptiveLoadingIndicator {
    if (platform.isCupertino) {
      return const CupertinoActivityIndicator();
    }
    return const CircularProgressIndicator();
  }
  
  Widget adaptiveLoadingScreen({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          adaptiveLoadingIndicator,
          if (message != null) ...[
            SizedBox(height: PlatformConstants.mediumSpace),
            Text(
              message,
              style: adaptiveBodyTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Dialog Extensions
extension DialogExtensions on BuildContext {
  Future<T?> showAdaptiveDialog<T>({
    required String title,
    Widget? content,
    required List<AdaptiveDialogAction> actions,
    bool barrierDismissible = true,
  }) {
    if (platform.isCupertino) {
      return showCupertinoDialog<T>(
        context: this,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: content,
          actions: actions.map((action) => CupertinoDialogAction(
            onPressed: action.onPressed,
            isDefaultAction: action.isPrimary,
            isDestructiveAction: action.isDestructive,
            child: Text(action.text),
          )).toList(),
        ),
      );
    }
    
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: actions.map((action) => TextButton(
          onPressed: action.onPressed,
          child: Text(
            action.text,
            style: TextStyle(
              color: action.isDestructive
                  ? adaptiveErrorColor
                  : action.isPrimary
                      ? adaptivePrimaryColor
                      : null,
              fontWeight: action.isPrimary ? FontWeight.bold : null,
            ),
          ),
        )).toList(),
      ),
    );
  }
  
  Future<T?> showAdaptiveBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    if (platform.isCupertino) {
      return showCupertinoModalPopup<T>(
        context: this,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: PlatformConstants.topBorderRadius,
          ),
          child: child,
        ),
      );
    }
    
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      shape: RoundedRectangleBorder(
        borderRadius: PlatformConstants.topBorderRadius,
      ),
      builder: (context) => child,
    );
  }
}

// Action Sheet Helper
class AdaptiveDialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  
  const AdaptiveDialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}