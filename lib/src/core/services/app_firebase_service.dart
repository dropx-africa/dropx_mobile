import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:dropx_mobile/firebase_options.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_log.dart';

// ── Shared event-key → title/body mapping (top-level so background isolate can use it) ──

({String title, String body})? _notificationForEventKey(String eventKey) {
  switch (eventKey) {
    case 'customer.order.placed':
      return (title: 'Order Placed', body: 'Your order has been placed successfully.');
    case 'customer.order.vendor_accepted':
      return (title: 'Order Accepted', body: 'The restaurant has accepted your order.');
    case 'customer.order.vendor_rejected':
      return (title: 'Order Rejected', body: 'Sorry, the restaurant could not accept your order.');
    case 'customer.order.rider_assigned':
      return (title: 'Rider Assigned', body: 'A rider has been assigned to pick up your order.');
    case 'customer.order.ready_for_pickup':
      return (title: 'Ready for Pickup', body: 'Your order is ready and waiting for the rider.');
    case 'customer.order.delivered':
      return (title: 'Order Delivered', body: 'Your order has been delivered. Enjoy!');
    case 'customer.order.cancelled_or_refunded':
      return (
        title: 'Order Cancelled',
        body: 'Your order was cancelled. Any applicable refund will be processed.',
      );
    case 'customer.parcel.recipient_confirmation':
      return (title: 'Parcel Confirmation', body: 'Please confirm receipt of your parcel.');
    case 'customer.parcel.placed':
      return (title: 'Parcel Booked', body: 'Your parcel has been booked successfully.');
    case 'customer.parcel.assigned':
      return (title: 'Rider Assigned', body: 'A rider has been assigned to your parcel.');
    case 'customer.parcel.picked_up':
      return (title: 'Parcel Picked Up', body: 'Your parcel has been picked up and is on the way.');
    case 'customer.parcel.in_transit':
      return (title: 'Parcel On the Way', body: 'Your parcel is heading to the recipient.');
    case 'customer.parcel.delivered':
      return (title: 'Parcel Delivered', body: 'Your parcel has been delivered successfully!');
    default:
      return null;
  }
}

// ── Background handler — must be top-level, runs in its own isolate ──────────

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const channelId = 'dropx_high_importance';
  const channelName = 'DropX Notifications';
  const channelDesc = 'Order, delivery, and parcel notifications';

  final eventKey = '${message.data['event_key'] ?? ''}'.trim();
  dev.log(
    '[Push] background message — event_key:$eventKey '
    'type:${message.data['aggregate_type']} id:${message.data['aggregate_id']}',
    name: 'AppFirebaseService',
  );

  // Only show a local notification for data-only messages — notification-type
  // messages are automatically displayed by the OS in background/terminated.
  if (message.notification != null || eventKey.isEmpty) return;

  final mapped = _notificationForEventKey(eventKey);
  if (mapped == null) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max,
        ),
      );

  await localNotifications.show(
    message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    mapped.title,
    mapped.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableLights: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
  dev.log('[Push] background local notification shown for "$eventKey"', name: 'AppFirebaseService');
}

// ── Interface ─────────────────────────────────────────────────────────────────

abstract class IAppFirebaseService {
  /// Singleton instance. Import this file and call [IAppFirebaseService.instance].
  static final IAppFirebaseService instance = AppFirebaseService._();

  /// Set up notification channels, background handler, foreground display,
  /// and push-tap deep-link routing. Call once from main() after Firebase.initializeApp().
  Future<void> initNotification();

  /// Fire a local notification immediately.
  Future<void> showLocalNotification({
    String title = 'DropX Test',
    String body = 'Local notification is working!',
    String? aggregateType,
    String? aggregateId,
  });
}

// ── Implementation ────────────────────────────────────────────────────────────

class AppFirebaseService implements IAppFirebaseService {
  AppFirebaseService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'dropx_high_importance';
  static const _channelName = 'DropX Notifications';
  static const _channelDesc = 'Order, delivery, and parcel notifications';

  // ── Event-key → notification title/body ───────────────────────────────────

  ({String title, String body})? _titleBodyForEventKey(String eventKey) =>
      _notificationForEventKey(eventKey);

  // ── Reusable notification details ──────────────────────────────────────────

  NotificationDetails get _notificationDetails => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          enableLights: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  @override
  Future<void> initNotification() async {
    AppLog.d('[Push] initNotification started');

    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    await _setupLocalNotifications();
    AppLog.d('[Push] local notifications ready');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    AppLog.d('[Push] foreground listener attached');

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      AppLog.d('[Push] app opened from background tap — event_key:${msg.data['event_key']} type:${msg.data['aggregate_type']} id:${msg.data['aggregate_id']}');
      _handlePushTap(msg.data);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      AppLog.d('[Push] app launched from terminated tap — event_key:${initial.data['event_key']} type:${initial.data['aggregate_type']} id:${initial.data['aggregate_id']}');
      _handlePushTap(initial.data);
    }

    AppLog.d('[Push] initNotification complete');
  }

  // ── Local notification setup ───────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        AppLog.d('[Push] local notification tapped — actionId:${response.actionId}');
        if (response.payload == null) return;
        try {
          final message = RemoteMessage.fromMap(
            jsonDecode(response.payload!) as Map<String, dynamic>,
          );
          _handlePushTap(message.data);
        } catch (e) {
          AppLog.e('[Push] failed to parse notification payload', e.toString());
        }
      },
    );

    // Create the Android high-importance channel.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
          ),
        );
  }

  // ── Foreground message display ─────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final eventKey = '${message.data['event_key'] ?? ''}'.trim();

    AppLog.d('[Push] foreground message — event_key:"$eventKey" title:"${notification?.title}" type:${message.data['aggregate_type']}');

    String? title;
    String? body;
    String? payload;

    if (notification != null) {
      // FCM notification field present — use it directly.
      title = notification.title ?? 'DropX';
      body = notification.body;
      payload = jsonEncode(message.toMap());
    } else if (eventKey.isNotEmpty) {
      // Data-only message — derive title/body from event_key.
      final mapped = _titleBodyForEventKey(eventKey);
      if (mapped != null) {
        title = mapped.title;
        body = mapped.body;
        payload = jsonEncode(message.toMap());
        AppLog.d('[Push] data-only message — showing local notification for "$eventKey"');
      }
    }

    if (title == null) {
      AppLog.d('[Push] foreground message skipped — no notification field and no known event_key');
      return;
    }

    await _localNotifications.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      _notificationDetails,
      payload: payload,
    );
    AppLog.d('[Push] foreground notification shown — title:"$title"');
  }

  // ── Push-tap routing ───────────────────────────────────────────────────────

  void _handlePushTap(Map<String, dynamic> data) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      AppLog.e('[Push] _handlePushTap — navigator not ready, ignoring tap');
      return;
    }

    final rawDeepLink = '${data['deep_link'] ?? ''}'.trim();
    final aggregateType = '${data['aggregate_type'] ?? ''}'.trim();
    final aggregateId = '${data['aggregate_id'] ?? ''}'.trim();
    final eventKey = '${data['event_key'] ?? ''}'.trim();

    AppLog.d('[Push] tap — event_key:"$eventKey" deepLink:"$rawDeepLink" type:"$aggregateType" id:"$aggregateId"');

    // 1. deep_link takes highest priority.
    if (rawDeepLink.startsWith('/')) {
      if (rawDeepLink.startsWith('/tracking/') && aggregateId.isNotEmpty) {
        AppLog.d('[Push] routing → orderTracking ($aggregateId) via deep_link');
        navigator.pushNamed(AppRoute.orderTracking, arguments: {'orderId': aggregateId});
        return;
      }
      if (rawDeepLink.startsWith('/parcels/') && aggregateId.isNotEmpty) {
        AppLog.d('[Push] routing → parcelTracking ($aggregateId) via deep_link');
        navigator.pushNamed(AppRoute.parcelTracking, arguments: {'parcelId': aggregateId});
        return;
      }
      if (rawDeepLink.startsWith('/transaction/') && aggregateId.isNotEmpty) {
        AppLog.d('[Push] routing → dashboard orders tab via /transaction/ deep_link');
        navigator.pushNamedAndRemoveUntil(
          AppRoute.dashboard,
          (route) => false,
          arguments: {'initialTab': 2},
        );
        return;
      }
    }

    // 2. event_key routing.
    if (eventKey == 'customer.order.delivered' ||
        eventKey == 'customer.order.cancelled_or_refunded') {
      AppLog.d('[Push] routing → dashboard orders tab via event_key "$eventKey"');
      navigator.pushNamedAndRemoveUntil(
        AppRoute.dashboard,
        (route) => false,
        arguments: {'initialTab': 2},
      );
      return;
    }
    if (eventKey.startsWith('customer.parcel.') && aggregateId.isNotEmpty) {
      AppLog.d('[Push] routing → parcelTracking ($aggregateId) via event_key "$eventKey"');
      navigator.pushNamed(AppRoute.parcelTracking, arguments: {'parcelId': aggregateId});
      return;
    }
    if (eventKey.startsWith('customer.order.') && aggregateId.isNotEmpty) {
      AppLog.d('[Push] routing → orderTracking ($aggregateId) via event_key "$eventKey"');
      navigator.pushNamed(AppRoute.orderTracking, arguments: {'orderId': aggregateId});
      return;
    }

    // 3. aggregate_type fallback.
    if (aggregateType == 'order_complete') {
      AppLog.d('[Push] routing → dashboard orders tab via aggregate_type order_complete');
      navigator.pushNamedAndRemoveUntil(
        AppRoute.dashboard,
        (route) => false,
        arguments: {'initialTab': 2},
      );
      return;
    }
    if (aggregateType == 'order' && aggregateId.isNotEmpty) {
      AppLog.d('[Push] routing → orderTracking ($aggregateId) via aggregate_type');
      navigator.pushNamed(AppRoute.orderTracking, arguments: {'orderId': aggregateId});
      return;
    }
    if (aggregateType == 'parcel' && aggregateId.isNotEmpty) {
      AppLog.d('[Push] routing → parcelTracking ($aggregateId) via aggregate_type');
      navigator.pushNamed(AppRoute.parcelTracking, arguments: {'parcelId': aggregateId});
      return;
    }

    AppLog.d('[Push] no route matched — falling back to notifications screen');
    navigator.pushNamed(AppRoute.notifications);
  }

  // ── Public helper ──────────────────────────────────────────────────────────

  @override
  Future<void> showLocalNotification({
    String title = 'DropX Test',
    String body = 'Local notification is working!',
    String? aggregateType,
    String? aggregateId,
  }) async {
    AppLog.d('🔔 [Push] showLocalNotification ENTER — title:"$title" type=$aggregateType id=$aggregateId');
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        _notificationDetails,
        payload: aggregateType != null
            ? '{"data":{"aggregate_type":"$aggregateType","aggregate_id":"${aggregateId ?? ''}"}}'
            : null,
      );
      AppLog.d('🔔 [Push] showLocalNotification SUCCESS — title:"$title"');
    } catch (e, st) {
      dev.log('🔴 [Push] showLocalNotification FAILED: $e\n$st', name: 'AppFirebaseService', error: e, stackTrace: st);
    }
  }
}
