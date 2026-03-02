import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppGoogleMap extends StatefulWidget {
  final LatLng initialTarget;
  final Set<Marker> markers;
  final Function(GoogleMapController)? onMapCreated;
  final double zoom;

  const AppGoogleMap({
    super.key,
    required this.initialTarget,
    this.markers = const <Marker>{},
    this.onMapCreated,
    this.zoom = 15.0,
  });

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  final bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text("Map failed to load.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Usually GoogleMap will log to console automatically if it fails.
    // There isn't an onError callback, but we can wrap error boundary eventually if needed.
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialTarget,
        zoom: widget.zoom,
      ),
      markers: widget.markers,
      onMapCreated: (controller) {
        if (kDebugMode) {
          print('[AppGoogleMap] Map Created successfully.');
        }
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
    );
  }
}
