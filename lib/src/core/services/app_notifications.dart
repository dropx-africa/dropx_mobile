import 'package:flutter/foundation.dart';
import 'package:dropx_mobile/src/core/services/app_firebase_service.dart';

class AppNotifications {
  AppNotifications._();

  // ── Orders ─────────────────────────────────────────────────────────────────

  static void orderPlaced(String orderId) {
    debugPrint('🔔 [Notif] orderPlaced called — orderId=$orderId');
    _show(
      title: 'Order Placed!',
      body: 'Your order has been placed and is being prepared.',
      aggregateType: 'order',
      aggregateId: orderId,
    );
  }

  static void orderStateChanged(String state, String orderId) {
    debugPrint('🔔 [Notif] orderStateChanged — state=$state orderId=$orderId');
    final msg = _orderStateMessage(state);
    if (msg == null) {
      debugPrint('🔔 [Notif] orderStateChanged — no notification mapped for state=$state (skipped)');
      return;
    }
    debugPrint('🔔 [Notif] orderStateChanged — firing "${msg.$1}"');
    _show(
      title: msg.$1,
      body: msg.$2,
      aggregateType: state == 'DELIVERED' ? 'order_complete' : 'order',
      aggregateId: orderId,
    );
  }

  // ── Parcels ────────────────────────────────────────────────────────────────

  static void parcelPlaced(String parcelId) {
    debugPrint('🔔 [Notif] parcelPlaced called — parcelId=$parcelId');
    _show(
      title: 'Parcel Booked!',
      body: 'Your parcel has been booked. A rider will be assigned shortly.',
      aggregateType: 'parcel',
      aggregateId: parcelId,
    );
  }

  static void parcelStateChanged(String state, String parcelId) {
    debugPrint('🔔 [Notif] parcelStateChanged — state=$state parcelId=$parcelId');
    final msg = _parcelStateMessage(state);
    if (msg == null) {
      debugPrint('🔔 [Notif] parcelStateChanged — no notification mapped for state=$state (skipped)');
      return;
    }
    debugPrint('🔔 [Notif] parcelStateChanged — firing "${msg.$1}"');
    _show(
      title: msg.$1,
      body: msg.$2,
      aggregateType: 'parcel',
      aggregateId: parcelId,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static (String, String)? _orderStateMessage(String state) {
    switch (state) {
      case 'ACCEPTED':
        return ('Rider Assigned', 'A rider has been assigned and is heading to pick up your order.');
      case 'PICKED_UP':
      case 'IN_TRANSIT':
        return ('Order On the Way', 'Your order has been picked up and is heading to you!');
      case 'ARRIVED_DROPOFF':
        return ('Rider Arrived', 'Your rider has arrived at your location.');
      case 'DELIVERED':
        return ('Order Delivered', 'Your order has been delivered successfully.');
      default:
        return null;
    }
  }

  static (String, String)? _parcelStateMessage(String state) {
    switch (state) {
      case 'ASSIGNED':
        return ('Rider Assigned', 'A rider has been assigned to your parcel.');
      case 'PICKED_UP':
        return ('Parcel Picked Up', 'Your parcel has been picked up and is on the way.');
      case 'IN_TRANSIT':
        return ('Parcel On the Way', 'Your parcel is heading to the recipient.');
      case 'DELIVERED':
        return ('Parcel Delivered!', 'Your parcel has been delivered successfully.');
      default:
        return null;
    }
  }

  static void _show({
    required String title,
    required String body,
    String? aggregateType,
    String? aggregateId,
  }) {
    debugPrint('🔔 [Notif] _show — title="$title" type=$aggregateType id=$aggregateId');
    IAppFirebaseService.instance.showLocalNotification(
      title: title,
      body: body,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
    );
    debugPrint('🔔 [Notif] _show — showLocalNotification called');
  }
}
