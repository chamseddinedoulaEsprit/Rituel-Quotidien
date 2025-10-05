import 'package:flutter/material.dart';
import 'package:rituel_quotidien/models/habit.dart';
import 'package:rituel_quotidien/services/completion_service.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime selectedDate;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.selectedDate,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadHabitData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(child: ListTile(title: Text('Chargement...')));
        }

        final data = snapshot.data!;
        final isCompleted = data['isCompleted'] as bool;
        final streak = data['streak'] as int;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: habit.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(habit.icon, color: habit.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (streak > 0) ...[
                              Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('$streak jours', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange)),
                            ] else
                              Text('Commencez votre série!', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted ? habit.color : Colors.grey.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.circle_outlined,
                      color: isCompleted ? Colors.white : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') _showDeleteDialog(context);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Modifier')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadHabitData() async {
    final completionService = CompletionService();
    final isCompleted = await completionService.isCompletedToday(habit.id, selectedDate);
    final streak = await completionService.getCurrentStreak(habit.id);
    return {'isCompleted': isCompleted, 'streak': streak};
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'habitude'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${habit.name}"? Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
