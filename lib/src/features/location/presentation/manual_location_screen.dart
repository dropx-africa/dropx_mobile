import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:permission_handler/permission_handler.dart';

class ManualLocationScreen extends StatefulWidget {
  final bool isGuest;
  const ManualLocationScreen({super.key, this.isGuest = false});

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  // Lagos, Nigeria
  static const CameraPosition _validLagos = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 14.4746,
  );

  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    // Request location permission from the system
    final status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted - location will be picked automatically by myLocationEnabled
      // The map will center on user's location
    } else {
      // Permission denied - user can manually select location on the map
      // Map stays centered on Lagos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _validLagos,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled:
                false, // Custom button if needed, or false for clean UI
            zoomControlsEnabled: false,
          ),

          // 2. Top Bar (Back + Search)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppColors.slate500),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Enter your address manually",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.slate400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet (Location content)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // User said "aint using green". Using Orange tint.
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      AppSpaces.h16,
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "123 Delivery Lane",
                              fontWeight: FontWeight.bold,
                            ),
                            AppSubText(
                              "Manhattan, New York, NY 10001",
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpaces.v24,
                  CustomButton(
                    text: 'Confirm Location',
                    backgroundColor: AppColors.primaryOrange,
                    onPressed: () async {
                      // Enforce Location Permission
                      final status = await Permission.location.status;
                      if (!status.isGranted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Location permission is required to use the app.",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          _requestLocationPermission();
                        }
                        return;
                      }

                      // Navigate to dashboard
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoute.dashboard,
                          (route) => false,
                          arguments: {'isGuest': widget.isGuest},
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
