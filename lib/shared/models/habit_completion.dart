class HabitCompletion {
  final String? id; // UUID from server
  final String habitId; // UUID reference
  final DateTime date;
  final bool isCompleted;
  final double value;
  final String? note;
  final DateTime? createdAt;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.date,
    this.isCompleted = true,
    this.value = 1.0,
    this.note,
    this.createdAt,
  });

  // For local SQLite storage (legacy - will be removed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T')[0],
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  // From local SQLite (legacy - will be removed)
  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id']?.toString(),
      habitId: map['habit_id']?.toString() ?? '',
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  // From server GraphQL response
  factory HabitCompletion.fromServerJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'],
      habitId: json['habit']['id'],
      date: DateTime.parse(json['date']),
      value: json['isCompleted'] ? 1.0 : 0.0,
      note: json['note'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    double? value,
    String? note,
    DateTime? createdAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion &&
        other.id == id &&
        other.habitId == habitId &&
        other.date == date &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        habitId.hashCode ^
        date.hashCode ^
        isCompleted.hashCode;
  }
}