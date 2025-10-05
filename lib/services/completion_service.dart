import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rituel_quotidien/models/habit_completion.dart';

class CompletionService {
  static const String _completionsKey = 'completions_list';

  Future<List<HabitCompletion>> getAllCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final completionsJson = prefs.getString(_completionsKey);
    
    if (completionsJson == null) {
      return [];
    }
    
    final List<dynamic> completionsList = jsonDecode(completionsJson);
    return completionsList.map((json) => HabitCompletion.fromJson(json)).toList();
  }

  Future<void> saveCompletions(List<HabitCompletion> completions) async {
    final prefs = await SharedPreferences.getInstance();
    final completionsJson = jsonEncode(completions.map((c) => c.toJson()).toList());
    await prefs.setString(_completionsKey, completionsJson);
  }

  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final allCompletions = await getAllCompletions();
    return allCompletions.where((c) => c.habitId == habitId).toList();
  }

  Future<bool> isCompletedToday(String habitId, DateTime date) async {
    final completions = await getCompletionsForHabit(habitId);
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return completions.any((c) => c.dateKey == dateKey);
  }

  Future<void> toggleCompletion(String habitId, String userId, DateTime date) async {
    final allCompletions = await getAllCompletions();
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final existingIndex = allCompletions.indexWhere(
      (c) => c.habitId == habitId && c.dateKey == dateKey,
    );

    if (existingIndex != -1) {
      allCompletions.removeAt(existingIndex);
    } else {
      final completion = HabitCompletion(
        id: 'completion_${DateTime.now().millisecondsSinceEpoch}',
        habitId: habitId,
        userId: userId,
        completedAt: date,
        createdAt: DateTime.now(),
      );
      allCompletions.add(completion);
    }

    await saveCompletions(allCompletions);
  }

  Future<int> getCurrentStreak(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);
    
    for (var i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (completions.any((c) => c.dateKey == dateKey)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  }

  Future<double> getMonthlySuccessRate(String habitId, DateTime month) async {
    final completions = await getCompletionsForHabit(habitId);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    
    final monthCompletions = completions.where((c) {
      return c.completedAt.year == month.year && c.completedAt.month == month.month;
    }).length;

    return monthCompletions / daysInMonth;
  }

  Future<Map<String, int>> getCompletionsByMonth(String habitId, int months) async {
    final completions = await getCompletionsForHabit(habitId);
    final Map<String, int> result = {};
    
    for (var i = 0; i < months; i++) {
      final date = DateTime.now().subtract(Duration(days: 30 * i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      final count = completions.where((c) {
        return c.completedAt.year == date.year && c.completedAt.month == date.month;
      }).length;
      
      result[key] = count;
    }
    
    return result;
  }

  Future<void> deleteCompletionsForHabit(String habitId) async {
    final allCompletions = await getAllCompletions();
    allCompletions.removeWhere((c) => c.habitId == habitId);
    await saveCompletions(allCompletions);
  }
}
