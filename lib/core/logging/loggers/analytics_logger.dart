import '../logger.dart';

class AnalyticsLogger {
  static final _logger = Logger.forModule('Analytics');

  static void logScreenView({
    required String screenName,
    String? previousScreen,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'Screen view: $screenName',
      metadata: {
        'screen': screenName,
        if (previousScreen != null) 'previousScreen': previousScreen,
        if (properties != null) ...properties,
      },
    );
  }

  static void logUserAction({
    required String action,
    required String category,
    String? label,
    num? value,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'User action: $action',
      metadata: {
        'action': action,
        'category': category,
        if (label != null) 'label': label,
        if (value != null) 'value': value,
        if (properties != null) ...properties,
      },
    );
  }

  static void logHabitEvent({
    required String event,
    required String habitId,
    String? habitName,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'Habit event: $event',
      metadata: {
        'event': event,
        'habitId': habitId,
        if (habitName != null) 'habitName': habitName,
        if (properties != null) ...properties,
      },
    );
  }

  static void logCommunityEvent({
    required String event,
    required String communityId,
    String? communityName,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'Community event: $event',
      metadata: {
        'event': event,
        'communityId': communityId,
        if (communityName != null) 'communityName': communityName,
        if (properties != null) ...properties,
      },
    );
  }

  static void logFeatureUsage({
    required String feature,
    required String action,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'Feature usage: $feature',
      metadata: {
        'feature': feature,
        'action': action,
        if (properties != null) ...properties,
      },
    );
  }

  static void logSearchEvent({
    required String searchType,
    required String query,
    int? resultCount,
    Map<String, dynamic>? filters,
  }) {
    _logger.info(
      'Search performed',
      metadata: {
        'searchType': searchType,
        'query': query,
        if (resultCount != null) 'resultCount': resultCount,
        if (filters != null) 'filters': filters,
      },
    );
  }

  static void logUserPreference({
    required String preference,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    _logger.info(
      'User preference changed: $preference',
      metadata: {
        'preference': preference,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    );
  }

  static void logOnboarding({
    required String step,
    required String action,
    int? stepNumber,
    int? totalSteps,
  }) {
    _logger.info(
      'Onboarding: $step',
      metadata: {
        'step': step,
        'action': action,
        if (stepNumber != null) 'stepNumber': stepNumber,
        if (totalSteps != null) 'totalSteps': totalSteps,
      },
    );
  }

  static void logEngagement({
    required String metric,
    required num value,
    String? period,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      'Engagement metric: $metric',
      metadata: {
        'metric': metric,
        'value': value,
        if (period != null) 'period': period,
        if (properties != null) ...properties,
      },
    );
  }

  static void logConversion({
    required String goal,
    required bool converted,
    String? source,
    Map<String, dynamic>? properties,
  }) {
    _logger.info(
      converted ? 'Conversion completed' : 'Conversion abandoned',
      metadata: {
        'goal': goal,
        'converted': converted,
        if (source != null) 'source': source,
        if (properties != null) ...properties,
      },
    );
  }
}