import 'package:flutter/material.dart';
import '../logger.dart';

class UILogger {
  static final _logger = Logger.forModule('UI');

  static void logNavigation({
    required String from,
    required String to,
    String? method,
    Map<String, dynamic>? arguments,
  }) {
    _logger.debug(
      'Navigation: $from → $to',
      metadata: {
        'from': from,
        'to': to,
        if (method != null) 'method': method,
        if (arguments != null) 'arguments': arguments,
      },
    );
  }

  static void logGesture({
    required String gesture,
    required String widget,
    String? action,
    Map<String, dynamic>? properties,
  }) {
    _logger.verbose(
      'Gesture detected: $gesture on $widget',
      metadata: {
        'gesture': gesture,
        'widget': widget,
        if (action != null) 'action': action,
        if (properties != null) ...properties,
      },
    );
  }

  static void logDialog({
    required String dialogName,
    required String action,
    dynamic result,
  }) {
    _logger.debug(
      'Dialog $action: $dialogName',
      metadata: {
        'dialog': dialogName,
        'action': action,
        if (result != null) 'result': result.toString(),
      },
    );
  }

  static void logSnackBar({
    required String message,
    String? action,
    bool? actionTaken,
  }) {
    _logger.debug(
      'SnackBar shown',
      metadata: {
        'message': message,
        if (action != null) 'action': action,
        if (actionTaken != null) 'actionTaken': actionTaken,
      },
    );
  }

  static void logFormValidation({
    required String form,
    required bool isValid,
    Map<String, String>? errors,
  }) {
    _logger.debug(
      'Form validation: $form',
      metadata: {
        'form': form,
        'isValid': isValid,
        if (errors != null && errors.isNotEmpty) 'errors': errors,
      },
    );
  }

  static void logWidgetError({
    required String widget,
    required Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    _logger.error(
      'Widget error: $widget',
      metadata: {
        'widget': widget,
        if (context != null) ...context,
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logRenderError({
    required String description,
    FlutterErrorDetails? details,
  }) {
    _logger.error(
      'Render error: $description',
      metadata: {
        'description': description,
        if (details != null) 'library': details.library,
      },
      error: details?.exception,
      stackTrace: details?.stack,
    );
  }

  static void logThemeChange({
    required String from,
    required String to,
    bool? isDarkMode,
  }) {
    _logger.info(
      'Theme changed: $from → $to',
      metadata: {
        'from': from,
        'to': to,
        if (isDarkMode != null) 'isDarkMode': isDarkMode,
      },
    );
  }

  static void logPlatformSwitch({
    required TargetPlatform from,
    required TargetPlatform to,
  }) {
    _logger.info(
      'Platform switched',
      metadata: {
        'from': from.toString(),
        'to': to.toString(),
      },
    );
  }

  static void logAccessibility({
    required String feature,
    required String action,
    Map<String, dynamic>? properties,
  }) {
    _logger.debug(
      'Accessibility: $feature',
      metadata: {
        'feature': feature,
        'action': action,
        if (properties != null) ...properties,
      },
    );
  }

  static void logAnimation({
    required String animation,
    required String state,
    Duration? duration,
  }) {
    _logger.verbose(
      'Animation $state: $animation',
      metadata: {
        'animation': animation,
        'state': state,
        if (duration != null) 'duration_ms': duration.inMilliseconds,
      },
    );
  }

  static void logLayout({
    required String widget,
    required String issue,
    Size? size,
    Map<String, dynamic>? constraints,
  }) {
    _logger.warning(
      'Layout issue: $widget',
      metadata: {
        'widget': widget,
        'issue': issue,
        if (size != null) 'size': '${size.width}x${size.height}',
        if (constraints != null) 'constraints': constraints,
      },
    );
  }
}