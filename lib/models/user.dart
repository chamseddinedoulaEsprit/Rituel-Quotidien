class User {
  final String id;
  final String name;
  final int totalPoints;
  final int level;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    this.totalPoints = 0,
    this.level = 1,
    this.badges = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get currentLevelPoints => totalPoints % 1000;
  int get pointsForNextLevel => 1000;
  double get levelProgress => currentLevelPoints / pointsForNextLevel;

  User copyWith({
    String? id,
    String? name,
    int? totalPoints,
    int? level,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalPoints': totalPoints,
    'level': level,
    'badges': badges,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    totalPoints: json['totalPoints'] ?? 0,
    level: json['level'] ?? 1,
    badges: List<String>.from(json['badges'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}
