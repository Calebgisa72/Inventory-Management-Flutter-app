import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _getToken();
      _configureFirebaseListeners();
      _isInitialized = true;
      print('FCM Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM Service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
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

    final bool? initialized = await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (initialized == true) {
      print('Local notifications initialized successfully');
    } else {
      print('Failed to initialize local notifications');
    }

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _getToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      print('FCM Token refreshed: $token');
    });
  }

  void _configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    _handleInitialMessage();
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'New Message',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    _handleNotificationAction(message.data);
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationAction(initialMessage.data);
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(id, title, body, platformDetails,
        payload: payload);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      _handleNotificationAction(data);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> data) {
    print('Handling notification action with data: $data');
    // Example: Use Navigator or state management to handle different types
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Method to show local notification for product addition
  Future<void> showProductAddedNotification(String productName) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Product Added Successfully!',
        body: 'New product "$productName" has been added to your inventory.',
        payload:
            jsonEncode({'type': 'product_added', 'productName': productName}),
      );
      print('Notification shown for product: $productName');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}

// Background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
}
