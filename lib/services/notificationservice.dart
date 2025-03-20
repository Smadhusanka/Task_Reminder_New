import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize the notification plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Request exact alarm permissions for Android 12+
    await requestExactAlarmsPermission();
  }

  // Request exact alarms permission for Android 12+
  Future<void> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    }
  }

  // Show immediate notification
  // Future<void> showNotification(int id, String title, String body) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //         'main_channel',
  //         'Main Notifications',
  //         channelDescription: "Notification channel for the app",
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         playSound: true,
  //       );

  //   const NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidDetails,
  //     iOS: DarwinNotificationDetails(),
  //   );

  //   await flutterLocalNotificationsPlugin.show(
  //     id,
  //     title,
  //     body,
  //     notificationDetails,
  //   );
  // }

  // Schedule notification
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime dateTime,
  ) async {
    try {
      // final scheduledTime = tz.TZDateTime.now(tz.local,).add(Duration(seconds: seconds));
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
        dateTime,
        tz.local,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel',
            'Main Notifications',
            channelDescription: 'Notification channel for the app',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
