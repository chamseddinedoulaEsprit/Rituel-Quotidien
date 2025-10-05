import 'package:flutter/material.dart';
import 'package:rituel_quotidien/models/habit.dart';
import 'package:rituel_quotidien/models/user.dart';
import 'package:rituel_quotidien/services/habit_service.dart';
import 'package:rituel_quotidien/services/completion_service.dart';
import 'package:rituel_quotidien/services/user_service.dart';
import 'package:rituel_quotidien/screens/habit_form_screen.dart';
import 'package:rituel_quotidien/screens/statistics_screen.dart';
import 'package:rituel_quotidien/screens/profile_screen.dart';
import 'package:rituel_quotidien/widgets/habit_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HabitService _habitService = HabitService();
  final CompletionService _completionService = CompletionService();
  final UserService _userService = UserService();
  
  List<Habit> _habits = [];
  User? _user;
  DateTime _selectedDate = DateTime.now();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final habits = await _habitService.getAllHabits();
    final user = await _userService.getUser();
    setState(() {
      _habits = habits;
      _user = user;
    });
  }

  Future<void> _toggleHabit(String habitId) async {
    await _completionService.toggleCompletion(habitId, _user!.id, _selectedDate);
    
    final isCompleted = await _completionService.isCompletedToday(habitId, _selectedDate);
    if (isCompleted && _isSameDay(_selectedDate, DateTime.now())) {
      await _userService.addPoints(10);
      
      final streak = await _completionService.getCurrentStreak(habitId);
      if (streak == 7) await _userService.addBadge('week_warrior');
      if (streak == 30) await _userService.addBadge('month_master');
      if (streak == 100) await _userService.addBadge('century_champion');
    }
    
    await _loadData();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HabitFormScreen()),
                );
                _loadData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle habitude'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistiques'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Rituel Quotidien', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
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
            ),
          ),
          actions: [
            if (_user != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Nv.${_user!.level}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(child: _buildDateSelector()),
        SliverToBoxAdapter(child: _buildQuickStats()),
        _habits.isEmpty ? SliverFillRemaining(child: _buildEmptyState()) : _buildHabitsList(),
      ],
    );
  }

  Widget _buildDateSelector() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          Column(
            children: [
              Text(
                isToday ? 'Aujourd\'hui' : DateFormat('EEEE', 'fr_FR').format(_selectedDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDate),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isSameDay(_selectedDate, DateTime.now()) ? null : () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_habits.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateTodayStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final stats = snapshot.data!;
        final completed = stats['completed'] as int;
        final total = stats['total'] as int;
        final percentage = total > 0 ? (completed / total * 100).toInt() : 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.check_circle, '$completed/$total', 'Complété'),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildStatItem(Icons.local_fire_department, '${stats['bestStreak']}', 'Meilleure série'),
              Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.3)),
              _buildStatItem(Icons.trending_up, '$percentage%', 'Réussite'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Future<Map<String, dynamic>> _calculateTodayStats() async {
    int completed = 0;
    int bestStreak = 0;

    for (final habit in _habits) {
      final isCompleted = await _completionService.isCompletedToday(habit.id, _selectedDate);
      if (isCompleted) completed++;

      final streak = await _completionService.getCurrentStreak(habit.id);
      if (streak > bestStreak) bestStreak = streak;
    }

    return {'completed': completed, 'total': _habits.length, 'bestStreak': bestStreak};
  }

  Widget _buildHabitsList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final habit = _habits[index];
            return HabitCard(
              habit: habit,
              selectedDate: _selectedDate,
              onToggle: () => _toggleHabit(habit.id),
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HabitFormScreen(habit: habit)),
                );
                _loadData();
              },
              onDelete: () async {
                await _habitService.deleteHabit(habit.id);
                await _completionService.deleteCompletionsForHabit(habit.id);
                _loadData();
              },
            );
          },
          childCount: _habits.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.self_improvement, size: 120, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            'Aucune habitude pour le moment',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez votre voyage vers une meilleure version de vous',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HabitFormScreen()),
              );
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Créer votre première habitude'),
          ),
        ],
      ),
    );
  }
}
