class Habit {
  final String? id; // UUID from server
  final String name;
  final List<String> phrases;
  final List<String> images;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final String color;
  final String icon;
  final bool isActive;
  final String? communityId;
  final String? communityName;
  final String? reminderTime;
  final List<int>? reminderDays;

  Habit({
    this.id,
    required this.name,
    required this.phrases,
    List<String>? images,
    required this.createdDate,
    this.updatedDate,
    required this.color,
    required this.icon,
    this.isActive = true,
    this.communityId,
    this.communityName,
    this.reminderTime,
    this.reminderDays,
  }) : images = images ?? [];

  // For local SQLite storage (legacy - will be removed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phrases': phrases.join('|||'),
      'images': images.join('|||'),
      'created_date': createdDate.toIso8601String(),
      'color': color,
      'icon': icon,
      'is_active': isActive ? 1 : 0,
      'community_id': communityId,
      'community_name': communityName,
    };
  }

  // From local SQLite (legacy - will be removed)
  factory Habit.fromMap(Map<String, dynamic> map) {
    final phrasesString = map['phrases'] as String? ?? '';
    final phrases = phrasesString.isEmpty ? <String>[] : phrasesString.split('|||');
    
    final imagesString = map['images'] as String? ?? '';
    final images = imagesString.isEmpty ? <String>[] : imagesString.split('|||');
    
    return Habit(
      id: map['id']?.toString(), // Convert int to string for compatibility
      name: map['name'] as String,
      phrases: phrases,
      images: images,
      createdDate: DateTime.parse(map['created_date'] as String),
      color: map['color'] as String,
      icon: map['icon'] as String? ?? 'science',
      isActive: (map['is_active'] as int) == 1,
      communityId: map['community_id'] as String?,
      communityName: map['community_name'] as String?,
    );
  }

  // From server GraphQL response
  factory Habit.fromServerJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      phrases: json['phrases'] != null 
          ? List<String>.from(json['phrases']) 
          : [],
      createdDate: DateTime.parse(json['createdAt']),
      updatedDate: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      color: json['color'] ?? '#FF6B6B',
      icon: json['icon'] ?? 'fitness_center',
      isActive: json['isActive'] ?? true,
      communityId: json['communityId'],
      communityName: json['community']?['name'],
      reminderTime: json['reminderTime'],
      reminderDays: json['reminderDays'] != null
          ? List<int>.from(json['reminderDays'])
          : null,
    );
  }

  // To server format for mutations
  Map<String, dynamic> toServerInput() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'phrases': phrases,
      'isActive': isActive,
      if (reminderTime != null) 'reminderTime': reminderTime,
      if (reminderDays != null) 'reminderDays': reminderDays,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    List<String>? phrases,
    List<String>? images,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? color,
    String? icon,
    bool? isActive,
    String? communityId,
    String? communityName,
    String? reminderTime,
    List<int>? reminderDays,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      phrases: phrases ?? this.phrases,
      images: images ?? this.images,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.phrases == phrases &&
        other.images == images &&
        other.createdDate == createdDate &&
        other.color == color &&
        other.icon == icon &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phrases.hashCode ^
        images.hashCode ^
        createdDate.hashCode ^
        color.hashCode ^
        icon.hashCode ^
        isActive.hashCode;
  }
}