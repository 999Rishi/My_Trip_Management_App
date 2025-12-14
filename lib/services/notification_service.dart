import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/expense.dart';
import '../models/trip.dart';

// Conditional imports for platform-specific implementations
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  Future<void> initialize() async {
    // Skip initialization on web as flutter_local_notifications doesn't fully support web
    if (kIsWeb) {
      print('Notifications not supported on web platform');
      return;
    }

    try {
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification:
                (int id, String? title, String? body, String? payload) async {
                  // Handle notification tap on iOS
                },
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _notificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              // Handle notification tap
            },
      );
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification(String title, String body) async {
    // Skip on web
    if (kIsWeb || _notificationsPlugin == null) {
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'trip_expense_channel',
            'Trip Expense Manager',
            channelDescription: 'Notifications for trip expenses',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin!.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: 'item x',
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> scheduleExpenseReminder(Expense expense, Trip trip) async {
    // Skip on web
    if (kIsWeb || _notificationsPlugin == null) {
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'expense_reminder_channel',
            'Expense Reminders',
            channelDescription: 'Reminders for shared expenses',
            importance: Importance.max,
            priority: Priority.high,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails();

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin!.show(
        expense.id.hashCode,
        'Expense Reminder',
        'You added an expense in ${trip.name}: ${expense.description} - ${expense.amount} ${expense.currency}',
        platformChannelSpecifics,
        payload: expense.id,
      );
    } catch (e) {
      print('Error scheduling expense reminder: $e');
    }
  }
}
