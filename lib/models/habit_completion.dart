class HabitCompletion {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final DateTime createdAt;

  HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    required this.createdAt,
  });

  String get dateKey => '${completedAt.year}-${completedAt.month.toString().padLeft(2, '0')}-${completedAt.day.toString().padLeft(2, '0')}';

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    String? userId,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'habitId': habitId,
    'userId': userId,
    'completedAt': completedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory HabitCompletion.fromJson(Map<String, dynamic> json) => HabitCompletion(
    id: json['id'],
    habitId: json['habitId'],
    userId: json['userId'],
    completedAt: DateTime.parse(json['completedAt']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}
