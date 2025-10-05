import 'package:flutter/material.dart';

enum HabitFrequency { daily, weekly }

class Habit {
  final String id;
  final String userId;
  final String name;
  final String iconName;
  final int colorValue;
  final HabitFrequency frequency;
  final List<int> weekDays;
  final TimeOfDay? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconName,
    required this.colorValue,
    this.frequency = HabitFrequency.daily,
    this.weekDays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(colorValue);

  IconData get icon {
    final iconMap = {
      'fitness': Icons.fitness_center,
      'book': Icons.menu_book,
      'water': Icons.water_drop,
      'sleep': Icons.bed,
      'meditation': Icons.self_improvement,
      'healthy_food': Icons.restaurant,
      'running': Icons.directions_run,
      'music': Icons.music_note,
      'study': Icons.school,
      'work': Icons.work,
    };
    return iconMap[iconName] ?? Icons.check_circle;
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    String? iconName,
    int? colorValue,
    HabitFrequency? frequency,
    List<int>? weekDays,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      weekDays: weekDays ?? this.weekDays,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'iconName': iconName,
    'colorValue': colorValue,
    'frequency': frequency.toString().split('.').last,
    'weekDays': weekDays,
    'reminderTime': reminderTime != null ? '${reminderTime!.hour}:${reminderTime!.minute}' : null,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['reminderTime'] != null) {
      final parts = json['reminderTime'].split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Habit(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      iconName: json['iconName'],
      colorValue: json['colorValue'],
      frequency: json['frequency'] == 'weekly' ? HabitFrequency.weekly : HabitFrequency.daily,
      weekDays: List<int>.from(json['weekDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      reminderTime: time,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
