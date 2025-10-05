import 'package:flutter/material.dart';
import 'package:rituel_quotidien/models/user.dart';
import 'package:rituel_quotidien/services/user_service.dart';
import 'package:rituel_quotidien/services/habit_service.dart';
import 'package:rituel_quotidien/services/completion_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final HabitService _habitService = HabitService();
  final CompletionService _completionService = CompletionService();

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        _user!.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _user!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLevelCard(),
                  const SizedBox(height: 24),
                  Text('Badges débloqués', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildBadgesGrid(),
                  const SizedBox(height: 24),
                  Text('Statistiques globales', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildGlobalStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Niveau ${_user!.level}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_user!.totalPoints} points totaux', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progression vers niveau ${_user!.level + 1}', style: Theme.of(context).textTheme.bodySmall),
                    Text('${_user!.currentLevelPoints}/${_user!.pointsForNextLevel}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _user!.levelProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final allBadges = [
      {'id': 'week_warrior', 'name': '7 jours', 'icon': Icons.military_tech, 'color': Colors.blue, 'description': 'Complété 7 jours d\'affilée'},
      {'id': 'month_master', 'name': '30 jours', 'icon': Icons.emoji_events, 'color': Colors.orange, 'description': 'Complété 30 jours d\'affilée'},
      {'id': 'century_champion', 'name': '100 jours', 'icon': Icons.workspace_premium, 'color': Colors.purple, 'description': 'Complété 100 jours d\'affilée'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badge = allBadges[index];
        final isUnlocked = _user!.badges.contains(badge['id']);

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(badge['name'] as String),
                content: Text(badge['description'] as String),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isUnlocked ? (badge['color'] as Color).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: isUnlocked ? Border.all(color: badge['color'] as Color, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  badge['icon'] as IconData,
                  color: isUnlocked ? badge['color'] as Color : Colors.grey,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  badge['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? badge['color'] as Color : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlobalStats() {
    return FutureBuilder<Map<String, int>>(
      future: _calculateGlobalStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return Column(
          children: [
            _buildStatRow(Icons.check_circle, 'Habitudes actives', '${stats['totalHabits']}'),
            const Divider(),
            _buildStatRow(Icons.done_all, 'Complétions totales', '${stats['totalCompletions']}'),
            const Divider(),
            _buildStatRow(Icons.local_fire_department, 'Plus longue série', '${stats['longestStreak']} jours'),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<Map<String, int>> _calculateGlobalStats() async {
    final habits = await _habitService.getAllHabits();
    final allCompletions = await _completionService.getAllCompletions();

    int longestStreak = 0;
    for (final habit in habits) {
      final streak = await _completionService.getCurrentStreak(habit.id);
      if (streak > longestStreak) longestStreak = streak;
    }

    return {
      'totalHabits': habits.length,
      'totalCompletions': allCompletions.length,
      'longestStreak': longestStreak,
    };
  }
}
