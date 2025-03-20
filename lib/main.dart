import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_preview/device_preview.dart';
import 'package:task_reminder/screens/homescreen.dart';
import 'package:task_reminder/services/notificationservice.dart';

// Request notification permission
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

// Check and request notification permission
Future<void> checkAndRequestPermission() async {
  PermissionStatus status = await Permission.notification.status;
  if (status.isDenied) {
    await Permission.notification.request();
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  await checkAndRequestPermission();
  NotificationService().initNotification();
  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: Homescreen(),
    );
  }
}
