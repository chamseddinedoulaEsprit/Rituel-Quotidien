import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rituel_quotidien/models/habit.dart';

class HabitService {
  static const String _habitsKey = 'habits_list';

  Future<List<Habit>> getAllHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(_habitsKey);
    
    if (habitsJson == null) {
      return [];
    }
    
    final List<dynamic> habitsList = jsonDecode(habitsJson);
    return habitsList.map((json) => Habit.fromJson(json)).toList();
  }

  Future<Habit?> getHabitById(String id) async {
    final habits = await getAllHabits();
    try {
      return habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_habitsKey, habitsJson);
  }

  Future<void> createHabit(Habit habit) async {
    final habits = await getAllHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit habit) async {
    final habits = await getAllHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    final habits = await getAllHabits();
    habits.removeWhere((h) => h.id == id);
    await saveHabits(habits);
  }
}
