class CommunityConstants {
  static const int defaultSearchLimit = 20;
  static const int maxSearchLimit = 100;
  static const int defaultPopularLimit = 10;
  
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxProposalDescriptionLength = 500;
  
  static const Duration queryTimeout = Duration(seconds: 10);
  static const Duration mutationTimeout = Duration(seconds: 15);
  
  static const int maxRetryAttempts = 3;
}

class CommunityCategories {
  static const List<String> all = [
    health,
    fitness,
    productivity,
    learning,
    mindfulness,
    creativity,
    social,
    finance,
    other,
  ];
  
  static const String health = 'health';
  static const String fitness = 'fitness';
  static const String productivity = 'productivity';
  static const String learning = 'learning';
  static const String mindfulness = 'mindfulness';
  static const String creativity = 'creativity';
  static const String social = 'social';
  static const String finance = 'finance';
  static const String other = 'other';
}

class DifficultyLevels {
  static const List<String> all = [easy, medium, hard];
  
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';
}

class Timeframes {
  static const List<String> all = [daily, weekly, monthly, allTime];
  
  static const String daily = 'DAILY';
  static const String weekly = 'WEEKLY';
  static const String monthly = 'MONTHLY';
  static const String allTime = 'ALL_TIME';
}