import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:engicore/core/services/encrypted_box_factory.dart';

/// Background message handler - must be top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background message received: ${message.messageId}');
}

/// Result of a notification operation.
sealed class NotificationResult {
  const NotificationResult();
}

/// Successful notification operation.
class NotificationSuccess extends NotificationResult {
  const NotificationSuccess();
}

/// Failed notification operation.
class NotificationFailure extends NotificationResult {
  const NotificationFailure(this.message);

  final String message;
}

/// Notification service for Firebase Cloud Messaging.
///
/// Handles push notifications for marketing announcements and updates.
/// Uses encrypted storage for notification persistence.
class NotificationService {
  NotificationService();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  Box<Map<String, dynamic>>? _notificationsBox;

  /// Initialize the notification service.
  Future<void> initialize() async {
    try {
      _messaging = FirebaseMessaging.instance;

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permissions (iOS & Android 13+)
      await _requestPermission();

      // Get FCM token (no logging for security)
      await _getToken();

      // Initialize local notifications for foreground display
      await _initializeLocalNotifications();

      // Set up message handlers
      _setupMessageHandlers();

      // Auto-subscribe to all_users topic
      await subscribeToTopic('all_users');

      // Open encrypted notifications storage box
      _notificationsBox = await EncryptedBoxFactory.openEncryptedBox<Map<String, dynamic>>(
        'notifications',
      );

      developer.log('NotificationService initialized successfully');
    } catch (e, s) {
      developer.log(
        'NotificationService initialization failed',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Request notification permissions.
  Future<void> _requestPermission() async {
    if (_messaging == null) return;

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        criticalAlert: false,
        provisional: false,
      );

      developer.log(
        'Notification permission status: ${settings.authorizationStatus}',
      );
    } catch (e) {
      developer.log('Failed to request permission: $e');
    }
  }

  /// Get FCM token securely (no logging).
  Future<String?> _getToken() async {
    if (_messaging == null) return null;

    try {
      return await _messaging!.getToken();
    } catch (e) {
      developer.log('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Get the current FCM token.
  Future<String?> getToken() => _getToken();

  /// Initialize local notifications for foreground display.
  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap.
  void _onNotificationTapped(NotificationResponse response) {
    developer.log('Notification tapped: ${response.payload}');
  }

  /// Set up message handlers for foreground and opened app.
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    _checkInitialMessage();
  }

  /// Handle foreground messages - show local notification.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log('Foreground message: ${message.notification?.title}');

    // Save to local storage
    await _saveNotification(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle when app opened from notification.
  void _handleMessageOpenedApp(RemoteMessage message) {
    developer.log('App opened from notification');
  }

  /// Check for initial message when app launches.
  Future<void> _checkInitialMessage() async {
    final message = await _messaging?.getInitialMessage();
    if (message != null) {
      developer.log('Initial message received');
    }
  }

  /// Show local notification for foreground messages.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (_localNotifications == null) return;

    final notification = message.notification;
    if (notification == null) return;

    // Rich media support - handle image URL
    BigPictureStyleInformation? bigPictureStyle;
    final imageUrl = message.notification?.android?.imageUrl ??
        message.data['image'] as String?;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        bigPictureStyle = BigPictureStyleInformation(
          DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          contentTitle: notification.title,
          summaryText: notification.body,
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
        );
      } catch (e) {
        developer.log('Failed to load notification image: $e');
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'marketing_channel',
      'Marketing Announcements',
      channelDescription: 'Product announcements and technical updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: bigPictureStyle,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications!.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }

  /// Subscribe to a topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging?.subscribeToTopic(topic);
      developer.log('Subscribed to topic: $topic');
    } catch (e) {
      developer.log('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging?.unsubscribeFromTopic(topic);
      developer.log('Unsubscribed from topic: $topic');
    } catch (e) {
      developer.log('Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// Check if notification box is available.
  bool get _isBoxAvailable =>
      _notificationsBox != null && _notificationsBox!.isOpen;

  /// Save notification to local storage.
  /// Only persists essential fields: title, body, timestamp, read.
  Future<NotificationResult> _saveNotification(RemoteMessage message) async {
    if (!_isBoxAvailable) {
      developer.log('Notifications box unavailable');
      return const NotificationFailure('Storage unavailable');
    }

    try {
      // Only persist essential, safe fields
      final notification = {
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };

      await _notificationsBox!.add(notification);
      return const NotificationSuccess();
    } catch (e) {
      developer.log('Failed to save notification: $e');
      return NotificationFailure(e.toString());
    }
  }

  /// Get all stored notifications.
  List<Map<dynamic, dynamic>> getStoredNotifications() {
    if (!_isBoxAvailable) return [];

    try {
      return _notificationsBox!.values.toList().reversed.toList();
    } catch (e) {
      developer.log('Failed to get stored notifications: $e');
      return [];
    }
  }

  /// Get unread notification count.
  int getUnreadCount() {
    if (!_isBoxAvailable) return 0;

    try {
      return _notificationsBox!.values
          .where((n) => n['read'] != true)
          .length;
    } catch (e) {
      developer.log('Failed to get unread count: $e');
      return 0;
    }
  }

  /// Mark all notifications as read.
  /// Returns success/failure for UI feedback.
  Future<NotificationResult> markAllAsRead() async {
    if (!_isBoxAvailable) {
      return const NotificationFailure('Storage unavailable');
    }

    try {
      for (int i = 0; i < _notificationsBox!.length; i++) {
        final notification = _notificationsBox!.getAt(i);
        if (notification != null) {
          notification['read'] = true;
          await _notificationsBox!.putAt(i, notification);
        }
      }
      return const NotificationSuccess();
    } catch (e) {
      developer.log('Failed to mark notifications as read: $e');
      return NotificationFailure(e.toString());
    }
  }

  /// Clear all notifications.
  Future<NotificationResult> clearAll() async {
    if (!_isBoxAvailable) {
      return const NotificationFailure('Storage unavailable');
    }

    try {
      await _notificationsBox!.clear();
      return const NotificationSuccess();
    } catch (e) {
      developer.log('Failed to clear notifications: $e');
      return NotificationFailure(e.toString());
    }
  }
}

/// Provider for NotificationService.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notifier for unread notification count.
class UnreadNotificationCountNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void reset() => state = 0;
  void set(int value) => state = value;
}

/// Provider for unread notification count.
final unreadNotificationCountProvider =
    NotifierProvider<UnreadNotificationCountNotifier, int>(
  UnreadNotificationCountNotifier.new,
);

/// Interest tracking for smart targeting.
class InterestTracker {
  static const String _boxName = 'interest_tracking';
  static Box<int>? _box;

  /// Initialize tracker with encrypted storage.
  static Future<void> initialize() async {
    try {
      _box = await EncryptedBoxFactory.openEncryptedBox<int>(_boxName);
    } catch (e) {
      developer.log('Failed to initialize interest tracker: $e');
    }
  }

  /// Track a screen visit for smart topic subscription.
  static Future<void> trackScreenVisit(
    String screenName,
    NotificationService notificationService,
  ) async {
    if (_box == null) return;

    try {
      final key = 'visit_$screenName';
      final currentCount = _box!.get(key, defaultValue: 0) ?? 0;
      final newCount = currentCount + 1;
      await _box!.put(key, newCount);

      // Smart targeting: subscribe to interest topic after 3 visits
      if (newCount == 3) {
        final topic = 'interest_${screenName.toLowerCase()}';
        await notificationService.subscribeToTopic(topic);
        developer.log('Auto-subscribed to topic: $topic based on interest');
      }
    } catch (e) {
      developer.log('Failed to track screen visit: $e');
    }
  }
}
