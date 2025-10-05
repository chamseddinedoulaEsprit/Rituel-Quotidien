import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rituel_quotidien/models/user.dart';

class UserService {
  static const String _userKey = 'current_user';

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) {
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Utilisateur',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await saveUser(newUser);
      return newUser;
    }
    
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> addPoints(int points) async {
    final user = await getUser();
    final newTotalPoints = user.totalPoints + points;
    final newLevel = (newTotalPoints / 1000).floor() + 1;
    
    await saveUser(user.copyWith(
      totalPoints: newTotalPoints,
      level: newLevel,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> addBadge(String badgeId) async {
    final user = await getUser();
    if (!user.badges.contains(badgeId)) {
      final newBadges = List<String>.from(user.badges)..add(badgeId);
      await saveUser(user.copyWith(
        badges: newBadges,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateName(String name) async {
    final user = await getUser();
    await saveUser(user.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    ));
  }
}
