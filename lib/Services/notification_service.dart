import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permissions granted');
      } else {
        print('❌ Notification permissions denied');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $_fcmToken');

      // Configure Firebase listeners
      _configureFirebaseListeners();

      _isInitialized = true;
      print('🚀 Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }

  void _configureFirebaseListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from notification: ${message.notification?.title}');
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      print('📢 Notification Title: ${message.notification!.title}');
      print('📝 Notification Body: ${message.notification!.body}');
      print('📊 Notification Data: ${message.data}');
    }
  }

  // Method to show product added notification (console version)
  Future<void> showProductAddedNotification(String productName) async {
    try {
      print('🎉 ========================================');
      print('🎉 PRODUCT ADDED SUCCESSFULLY!');
      print('🎉 Product Name: $productName');
      print('🎉 Added at: ${DateTime.now().toString()}');
      print('🎉 ========================================');

      // You can also show a snackbar or dialog here if you have access to context
      return;
    } catch (e) {
      print('❌ Error showing product notification: $e');
    }
  }

  // // Method to show notification with context (for SnackBar)
  // void showProductAddedSnackBar(BuildContext context, String productName) {
  //   try {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const Icon(Icons.check_circle, color: Colors.white),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 'Product "$productName" added successffully!',
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: Colors.green,
  //         duration: const Duration(seconds: 3),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );

      print('✅ SnackBar notification shown for product: $productName');
    } catch (e) {
      print('❌ Error showing SnackBar: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('📡 Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('📡 Unsubscribed from topic: $topic');
  }
}
