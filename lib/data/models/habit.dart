class Habit {
  final int? id;
  final String name;
  final List<String> phrases;
  final List<String> images;
  final DateTime createdDate;
  final String color;
  final String icon;
  final bool isActive;
  final bool isFromCommunity;
  final bool isPublic;
  final String? communityId;
  final String? communityName;

  Habit({
    this.id,
    required this.name,
    required this.phrases,
    List<String>? images,
    required this.createdDate,
    required this.color,
    required this.icon,
    this.isActive = true,
    this.isFromCommunity = false,
    this.isPublic = false,
    this.communityId,
    this.communityName,
  }) : images = images ?? [];

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
      'is_from_community': isFromCommunity ? 1 : 0,
      'is_public': isPublic ? 1 : 0,
      'community_id': communityId,
      'community_name': communityName,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    final phrasesString = map['phrases'] as String? ?? '';
    final phrases = phrasesString.isEmpty ? <String>[] : phrasesString.split('|||');
    
    final imagesString = map['images'] as String? ?? '';
    final images = imagesString.isEmpty ? <String>[] : imagesString.split('|||');
    
    return Habit(
      id: map['id'] as int?,
      name: map['name'] as String,
      phrases: phrases,
      images: images,
      createdDate: DateTime.parse(map['created_date'] as String),
      color: map['color'] as String,
      icon: map['icon'] as String? ?? 'science', // Default to atom/science icon
      isActive: (map['is_active'] as int) == 1,
      isFromCommunity: (map['is_from_community'] as int? ?? 0) == 1,
      isPublic: (map['is_public'] as int? ?? 0) == 1,
      communityId: map['community_id'] as String?,
      communityName: map['community_name'] as String?,
    );
  }

  Habit copyWith({
    int? id,
    String? name,
    List<String>? phrases,
    List<String>? images,
    DateTime? createdDate,
    String? color,
    String? icon,
    bool? isActive,
    bool? isFromCommunity,
    bool? isPublic,
    String? communityId,
    String? communityName,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      phrases: phrases ?? this.phrases,
      images: images ?? this.images,
      createdDate: createdDate ?? this.createdDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isFromCommunity: isFromCommunity ?? this.isFromCommunity,
      isPublic: isPublic ?? this.isPublic,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
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