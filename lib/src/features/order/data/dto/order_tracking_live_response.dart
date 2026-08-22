/// Manual (non-codegen) DTOs for `GET /orders/:id/live-summary`.
///
/// The backend nests tracking freshness fields (`source`, `is_stale`,
/// `stale_after_seconds`, `accuracy_m`, `location`) under a `tracking`
/// object, and `delivery_otp` is metadata only (`required`/`issued`/
/// `available`) — it never carries the raw code. The actual code still
/// comes from the dedicated `GET /orders/:id/delivery-otp` endpoint.
class OrderTrackingLiveResponse {
  final bool ok;
  final OrderTrackingLiveData data;

  const OrderTrackingLiveResponse({required this.ok, required this.data});

  factory OrderTrackingLiveResponse.fromJson(Map<String, dynamic> json) {
    return OrderTrackingLiveResponse(
      ok: json['ok'] as bool? ?? true,
      data: OrderTrackingLiveData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class OrderTrackingLiveData {
  final String orderId;
  final String state;
  final OrderTrackingRider? rider;
  final int? etaMinutes;
  final OrderTrackingLocation? location;
  final List<dynamic>? timeline;
  final int? staleAfterSeconds;
  final bool? isStale;
  final int? ageSeconds;
  final String? source;
  final num? accuracyM;
  final int? lastEventSeq;
  final OrderVendorHandoff? vendorHandoff;

  const OrderTrackingLiveData({
    required this.orderId,
    required this.state,
    this.rider,
    this.etaMinutes,
    this.location,
    this.timeline,
    this.staleAfterSeconds,
    this.isStale,
    this.ageSeconds,
    this.source,
    this.accuracyM,
    this.lastEventSeq,
    this.vendorHandoff,
  });

  factory OrderTrackingLiveData.fromJson(Map<String, dynamic> json) {
    final riderJson = json['rider'] as Map<String, dynamic>?;
    final tracking = json['tracking'] as Map<String, dynamic>?;
    final locationJson = tracking?['location'] as Map<String, dynamic>?;
    final vendorHandoffJson = json['vendor_handoff'] as Map<String, dynamic>?;

    return OrderTrackingLiveData(
      orderId: json['order_id'] as String? ?? '',
      state: json['state'] as String? ?? '',
      rider: riderJson != null
          ? OrderTrackingRider.fromJson(riderJson)
          : null,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      location: locationJson != null
          ? OrderTrackingLocation.fromJson(locationJson)
          : null,
      timeline: json['timeline'] as List<dynamic>?,
      staleAfterSeconds: (tracking?['stale_after_seconds'] as num?)?.toInt(),
      isStale: tracking?['is_stale'] as bool?,
      ageSeconds: (tracking?['age_seconds'] as num?)?.toInt(),
      source: tracking?['source'] as String?,
      accuracyM: tracking?['accuracy_m'] as num?,
      lastEventSeq: (json['last_event_seq'] as num?)?.toInt(),
      vendorHandoff: vendorHandoffJson != null
          ? OrderVendorHandoff.fromJson(vendorHandoffJson)
          : null,
    );
  }
}

/// Vendor prep/handoff state — lets the UI show the vendor's prep time as
/// its own line item instead of folding it silently into one opaque ETA.
class OrderVendorHandoff {
  final String? status;
  final int? prepEtaMinutes;
  final String? readyAt;
  final String? handoffAt;
  final bool? handoffVerified;

  const OrderVendorHandoff({
    this.status,
    this.prepEtaMinutes,
    this.readyAt,
    this.handoffAt,
    this.handoffVerified,
  });

  factory OrderVendorHandoff.fromJson(Map<String, dynamic> json) {
    return OrderVendorHandoff(
      status: json['status'] as String?,
      prepEtaMinutes: (json['prep_eta_minutes'] as num?)?.toInt(),
      readyAt: json['ready_at'] as String?,
      handoffAt: json['handoff_at'] as String?,
      handoffVerified: json['handoff_verified'] as bool?,
    );
  }
}

class OrderTrackingRider {
  final String id;
  final String name;
  final String? phoneE164;
  final String? photoUrl;
  final String? vehicle;
  final String? plateNumber;
  final num? rating;

  const OrderTrackingRider({
    required this.id,
    required this.name,
    this.phoneE164,
    this.photoUrl,
    this.vehicle,
    this.plateNumber,
    this.rating,
  });

  factory OrderTrackingRider.fromJson(Map<String, dynamic> json) {
    return OrderTrackingRider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneE164: json['phone_e164'] as String?,
      photoUrl: json['photo_url'] as String?,
      vehicle: json['vehicle'] as String?,
      plateNumber: json['plate_number'] as String?,
      rating: json['rating'] as num?,
    );
  }
}

class OrderTrackingLocation {
  final double lat;
  final double lng;
  final String updatedAt;
  final String? source;
  final num? accuracyM;

  const OrderTrackingLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
    this.source,
    this.accuracyM,
  });

  factory OrderTrackingLocation.fromJson(Map<String, dynamic> json) {
    return OrderTrackingLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      updatedAt: json['updated_at'] as String? ?? '',
      source: json['source'] as String?,
      accuracyM: json['accuracy_m'] as num?,
    );
  }
}
