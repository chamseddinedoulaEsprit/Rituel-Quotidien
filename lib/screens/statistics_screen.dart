import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:rituel_quotidien/models/habit.dart';
import 'package:rituel_quotidien/services/habit_service.dart';
import 'package:rituel_quotidien/services/completion_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final HabitService _habitService = HabitService();
  final CompletionService _completionService = CompletionService();
  
  List<Habit> _habits = [];
  Habit? _selectedHabit;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _habitService.getAllHabits();
    setState(() {
      _habits = habits;
      if (_habits.isNotEmpty && _selectedHabit == null) {
        _selectedHabit = _habits.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_habits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 100, color: Colors.grey.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Aucune habitude à analyser', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHabitSelector(),
          const SizedBox(height: 24),
          if (_selectedHabit != null) ...[
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildCalendarView(),
            const SizedBox(height: 24),
            _buildMonthlyChart(),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<Habit>(
        value: _selectedHabit,
        isExpanded: true,
        underline: const SizedBox(),
        items: _habits.map((habit) {
          return DropdownMenuItem(
            value: habit,
            child: Row(
              children: [
                Icon(habit.icon, color: habit.color, size: 24),
                const SizedBox(width: 12),
                Text(habit.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (habit) => setState(() => _selectedHabit = habit),
      ),
    );
  }

  Widget _buildStatsCards() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        return Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_fire_department, '${stats['currentStreak']}', 'Série actuelle', Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.calendar_today, '${stats['totalCompleted']}', 'Total complété', Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.trending_up, '${stats['successRate']}%', 'Taux de réussite', Colors.blue)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateStats() async {
    if (_selectedHabit == null) return {};

    final streak = await _completionService.getCurrentStreak(_selectedHabit!.id);
    final completions = await _completionService.getCompletionsForHabit(_selectedHabit!.id);
    final daysSinceCreation = DateTime.now().difference(_selectedHabit!.createdAt).inDays + 1;
    final successRate = daysSinceCreation > 0 ? ((completions.length / daysSinceCreation) * 100).toInt() : 0;

    return {
      'currentStreak': streak,
      'totalCompleted': completions.length,
      'successRate': successRate,
    };
  }

  Widget _buildCalendarView() {
    return FutureBuilder<List<DateTime>>(
      future: _getCompletedDates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final completedDates = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isCompleted = completedDates.any((d) => isSameDay(d, day));
                  if (isCompleted) {
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _selectedHabit!.color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${day.day}', style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  }
                  return null;
                },
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
        );
      },
    );
  }

  Future<List<DateTime>> _getCompletedDates() async {
    if (_selectedHabit == null) return [];
    final completions = await _completionService.getCompletionsForHabit(_selectedHabit!.id);
    return completions.map((c) => c.completedAt).toList();
  }

  Widget _buildMonthlyChart() {
    return FutureBuilder<Map<String, int>>(
      future: _completionService.getCompletionsByMonth(_selectedHabit!.id, 6),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final entries = data.entries.toList().reversed.toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progression mensuelle', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 31,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= entries.length) return const Text('');
                              final date = entries[value.toInt()].key;
                              final parts = date.split('-');
                              final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
                              return Text(monthNames[int.parse(parts[1]) - 1], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      barGroups: entries.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.toDouble(),
                              color: _selectedHabit!.color,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
