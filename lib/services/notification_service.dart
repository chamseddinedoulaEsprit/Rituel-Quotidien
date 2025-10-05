import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rituel_quotidien/models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    final time = habit.reminderTime!;
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _notifications.periodicallyShow(
      habit.id.hashCode,
      'Rappel: ${habit.name}',
      'N\'oubliez pas de compléter votre habitude aujourd\'hui!',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Rappels d\'habitudes',
          channelDescription: 'Notifications pour vos habitudes quotidiennes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(habitId.hashCode);
  }
}
