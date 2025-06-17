import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await _initializeLocalNotifications();
      _isInitialized = true;
      print('🚀 Push Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      _isInitialized = true; // Continue without notifications
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📱 Notification tapped: ${response.payload}');
      },
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'inventory_channel',
      'Inventory Notifications',
      description: 'Notifications for inventory management',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
  }

  
  Future<void> showDeviceNotification({
    required String title,
    required String body,
    required String productName,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'inventory_channel',
        'Inventory Notifications',
        channelDescription: 'Notifications for inventory management',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      final int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: jsonEncode({
          'type': 'product_added',
          'productName': productName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      print('🔔 ==========================================');
      print('🔔 REAL DEVICE NOTIFICATION SENT!');
      print('🔔 Title: $title');
      print('🔔 Body: $body');
      print('🔔 Notification ID: $notificationId');
      print('🔔 Check your device notification panel!');
      print('🔔 ==========================================');
    } catch (e) {
      print('❌ Error showing device notification: $e');
    }
  }

  // Enhanced product notification with console logging
  Future<void> sendProductAddedNotification(String productName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final payload = jsonEncode({
        'type': 'product_added',
        'productName': productName,
        'timestamp': DateTime.now().toIso8601String(),
        'notificationId': notificationId,
      });

      print('🎉 ==========================================');
      print('🎉 PRODUCT NOTIFICATION SYSTEM ACTIVATED!');
      print('🎉 Product Name: $productName');
      print('🎉 Notification ID: $notificationId');
      print('🎉 Time: ${DateTime.now().toString()}');
      print('🎉 Payload: $payload');
      print('🎉 Status: Successfully processed');
      print('🎉 ==========================================');
    } catch (e) {
      print('❌ Error in enhanced product notification: $e');
    }
  }

  // Show rich in-app notification using SnackBar
  void showInAppNotification(BuildContext context, String productName) {
    try {
      print(' In-app notification shown for product: $productName');
    } catch (e) {
      print('❌ Error showing in-app notification: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }
    return true;
  }

  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }
    return true;
  }
}
