import 'package:flutter/material.dart';
import 'package:rituel_quotidien/models/habit.dart';
import 'package:rituel_quotidien/services/habit_service.dart';
import 'package:rituel_quotidien/services/user_service.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final HabitService _habitService = HabitService();
  final UserService _userService = UserService();

  String _selectedIcon = 'fitness';
  Color _selectedColor = Colors.blue;
  HabitFrequency _frequency = HabitFrequency.daily;
  TimeOfDay? _reminderTime;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'fitness', 'icon': Icons.fitness_center, 'label': 'Sport'},
    {'name': 'book', 'icon': Icons.menu_book, 'label': 'Lecture'},
    {'name': 'water', 'icon': Icons.water_drop, 'label': 'Hydratation'},
    {'name': 'sleep', 'icon': Icons.bed, 'label': 'Sommeil'},
    {'name': 'meditation', 'icon': Icons.self_improvement, 'label': 'Méditation'},
    {'name': 'healthy_food', 'icon': Icons.restaurant, 'label': 'Nutrition'},
    {'name': 'running', 'icon': Icons.directions_run, 'label': 'Course'},
    {'name': 'music', 'icon': Icons.music_note, 'label': 'Musique'},
    {'name': 'study', 'icon': Icons.school, 'label': 'Étude'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Travail'},
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = widget.habit!.iconName;
      _selectedColor = widget.habit!.color;
      _frequency = widget.habit!.frequency;
      _reminderTime = widget.habit!.reminderTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await _userService.getUser();
    final now = DateTime.now();

    final habit = Habit(
      id: widget.habit?.id ?? 'habit_${now.millisecondsSinceEpoch}',
      userId: user.id,
      name: _nameController.text.trim(),
      iconName: _selectedIcon,
      colorValue: _selectedColor.value,
      frequency: _frequency,
      reminderTime: _reminderTime,
      createdAt: widget.habit?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.habit == null) {
      await _habitService.createHabit(habit);
    } else {
      await _habitService.updateHabit(habit);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Nouvelle habitude' : 'Modifier l\'habitude'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'habitude',
                hintText: 'Ex: Faire du sport',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text('Choisissez une icône', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((iconData) {
                final isSelected = _selectedIcon == iconData['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconData['name']),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: _selectedColor, width: 2) : null,
                    ),
                    child: Column(
                      children: [
                        Icon(iconData['icon'], color: isSelected ? _selectedColor : Colors.grey, size: 28),
                        const SizedBox(height: 4),
                        Text(iconData['label'], style: TextStyle(fontSize: 10, color: isSelected ? _selectedColor : Colors.grey), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Choisissez une couleur', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Fréquence', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<HabitFrequency>(
              segments: [
                ButtonSegment(value: HabitFrequency.daily, label: Text('Quotidienne'), icon: Icon(Icons.today)),
                ButtonSegment(value: HabitFrequency.weekly, label: Text('Hebdomadaire'), icon: Icon(Icons.calendar_month)),
              ],
              selected: {_frequency},
              onSelectionChanged: (Set<HabitFrequency> newSelection) {
                setState(() => _frequency = newSelection.first);
              },
            ),
            const SizedBox(height: 24),
            Text('Rappel', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(_reminderTime != null ? 'Rappel à ${_reminderTime!.format(context)}' : 'Aucun rappel'),
              trailing: _reminderTime != null ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _reminderTime = null)) : null,
              onTap: _pickTime,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
            ),
          ],
        ),
      ),
    );
  }
}
