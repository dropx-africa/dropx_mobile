class ParcelTrackingLiveResponse {
  final bool ok;
  final ParcelTrackingLiveData data;

  const ParcelTrackingLiveResponse({required this.ok, required this.data});

  factory ParcelTrackingLiveResponse.fromJson(Map<String, dynamic> json) {
    return ParcelTrackingLiveResponse(
      ok: json['ok'] as bool? ?? true,
      data: ParcelTrackingLiveData.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}

class ParcelTrackingLiveData {
  final String parcelId;
  final String state;
  final String? assignmentStatus;
  final bool trackingAvailable;
  final ParcelTrackingRider? rider;
  final int? etaMinutes;
  final ParcelTrackingLocation? location;
  final List<dynamic>? timeline;
  final int? staleAfterSeconds;
  final bool isStale;
  final String? source;
  final num? accuracyM;
  final int? lastEventSeq;
  final bool recipientConfirmationRequired;
  final String? recipientConfirmationStatus;

  const ParcelTrackingLiveData({
    required this.parcelId,
    required this.state,
    this.assignmentStatus,
    this.trackingAvailable = false,
    this.rider,
    this.etaMinutes,
    this.location,
    this.timeline,
    this.staleAfterSeconds,
    this.isStale = false,
    this.source,
    this.accuracyM,
    this.lastEventSeq,
    this.recipientConfirmationRequired = false,
    this.recipientConfirmationStatus,
  });

  factory ParcelTrackingLiveData.fromJson(Map<String, dynamic> json) {
    final riderJson = json['rider'] as Map<String, dynamic>?;
    final locationJson = json['location'] as Map<String, dynamic>?;

    return ParcelTrackingLiveData(
      parcelId: json['parcel_id'] as String? ?? '',
      state: json['state'] as String? ?? '',
      assignmentStatus: json['assignment_status'] as String?,
      trackingAvailable: json['tracking_available'] as bool? ?? false,
      rider: riderJson != null ? ParcelTrackingRider.fromJson(riderJson) : null,
      etaMinutes: json['eta_minutes'] as int?,
      location:
          locationJson != null
              ? ParcelTrackingLocation.fromJson(locationJson)
              : null,
      timeline: json['timeline'] as List<dynamic>?,
      staleAfterSeconds: json['stale_after_seconds'] as int?,
      isStale: json['is_stale'] as bool? ?? false,
      source: json['source'] as String?,
      accuracyM: json['accuracy_m'] as num?,
      lastEventSeq: json['last_event_seq'] as int?,
      recipientConfirmationRequired:
          json['recipient_confirmation_required'] as bool? ?? false,
      recipientConfirmationStatus:
          json['recipient_confirmation_status'] as String?,
    );
  }
}

class ParcelTrackingRider {
  final String id;
  final String name;
  final String? phoneE164;
  final String? photoUrl;
  final String? vehicle;
  final String? plateNumber;
  final num? rating;
  final String? status;

  const ParcelTrackingRider({
    required this.id,
    required this.name,
    this.phoneE164,
    this.photoUrl,
    this.vehicle,
    this.plateNumber,
    this.rating,
    this.status,
  });

  factory ParcelTrackingRider.fromJson(Map<String, dynamic> json) {
    return ParcelTrackingRider(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneE164: json['phone_e164'] as String?,
      photoUrl: json['photo_url'] as String?,
      vehicle: json['vehicle'] as String?,
      plateNumber: json['plate_number'] as String?,
      rating: json['rating'] as num?,
      status: json['status'] as String?,
    );
  }
}

class ParcelTrackingLocation {
  final double lat;
  final double lng;
  final String updatedAt;
  final String? source;
  final num? accuracyM;

  const ParcelTrackingLocation({
    required this.lat,
    required this.lng,
    required this.updatedAt,
    this.source,
    this.accuracyM,
  });

  factory ParcelTrackingLocation.fromJson(Map<String, dynamic> json) {
    return ParcelTrackingLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      updatedAt: json['updated_at'] as String? ?? '',
      source: json['source'] as String?,
      accuracyM: json['accuracy_m'] as num?,
    );
  }
}
