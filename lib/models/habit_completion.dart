class HabitCompletion {
  final int? id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  HabitCompletion copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? isCompleted,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
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