import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Deep link handling
      },
    );

    await requestPermissions();
  }

  Future<bool?> requestPermissions() async {
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission();
    }
    return true;
  }

  Future<void> showDailyCompletionReminder() async {
    await requestPermissions();
    const androidDetails = AndroidNotificationDetails(
      'daily_completion_channel',
      'Daily Expense Reminders',
      channelDescription: 'Reminds you to record daily expenses before end of day',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      1001,
      'MyExpense Daily Check',
      'Have you recorded all your expenses for today?',
      notificationDetails,
    );
  }

  Future<void> showBudgetWarningNotification(String categoryName, double percentage) async {
    await requestPermissions();
    const androidDetails = AndroidNotificationDetails(
      'budget_warning_channel',
      'Budget Warning Notifications',
      channelDescription: 'Notifies when spending approaches budget limits',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      2001,
      'Budget Threshold Alert',
      'You have used ${percentage.toStringAsFixed(0)}% of your $categoryName budget.',
      notificationDetails,
    );
  }
}
