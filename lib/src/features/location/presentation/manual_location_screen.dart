import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

class ManualLocationScreen extends ConsumerStatefulWidget {

  const ManualLocationScreen({super.key});

  @override
  ConsumerState<ManualLocationScreen> createState() =>
      _ManualLocationScreenState();
}

class _ManualLocationScreenState extends ConsumerState<ManualLocationScreen> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  GoogleMapController? _mapController;
  bool _mapReady = false;

  static const LatLng _lagosDefault = LatLng(6.5244, 3.3792);
  static const CameraPosition _initialPosition = CameraPosition(
    target: _lagosDefault,
    zoom: 14.4746,
  );

  LatLng _pinPosition = _lagosDefault;
  bool _locationGranted = false;
  bool _locationLoading = true;
  String? _gpsAddress;

  Timer? _debounce;
  List<GeocodeResult> _geocodeResults = [];
  bool _isSearching = false;
  bool _showDropdown = false;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    final granted = await _requestLocationPermission();
    if (!mounted) return;
    setState(() {
      _locationGranted = granted;
      _locationLoading = false;
    });
    if (granted && _mapReady) await _moveToCurrentLocation();
  }

  Future<bool> _requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showLocationServiceDialog();
      return false;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return false;
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) _showSettingsDialog();
      return false;
    }
    return true;
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _pinPosition = ll;
        _gpsAddress = 'Locating...';
      });
      // Reverse-geocode to get a real address
      final address = await ref.read(placesServiceProvider).reverseGeocode(ll);
      if (!mounted) return;
      setState(() {
        if (address != null && address.isNotEmpty) {
          _selectedAddress = address;
          _gpsAddress = address;
        } else {
          _gpsAddress = 'Your current location';
        }
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: ll, zoom: 16)),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        final ll = LatLng(last.latitude, last.longitude);
        setState(() {
          _pinPosition = ll;
          _gpsAddress = 'Locating...';
        });
        final address2 = await ref
            .read(placesServiceProvider)
            .reverseGeocode(ll);
        if (!mounted) return;
        setState(() {
          if (address2 != null && address2.isNotEmpty) {
            _selectedAddress = address2;
            _gpsAddress = address2;
          } else {
            _gpsAddress = 'Your last known location';
          }
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: ll, zoom: 16)),
        );
      }
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() {
        _geocodeResults = [];
        _isSearching = _showDropdown = false;
        _selectedAddress = null;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _showDropdown = false;
      _selectedAddress = null;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await ref
            .read(locationRepositoryProvider)
            .geocode(query);
        if (mounted) {
          setState(() {
            _geocodeResults = results;
            _isSearching = false;
            _showDropdown = results.isNotEmpty;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _geocodeResults = [];
            _isSearching = false;
            _showDropdown = false;
          });
        }
      }
    });
  }

  void _onGeocodeResultSelected(GeocodeResult result) {
    _addressController.text = result.formattedAddress;
    _searchFocusNode.unfocus();
    final location = LatLng(result.lat, result.lng);
    setState(() {
      _geocodeResults = [];
      _showDropdown = false;
      _isSearching = false;
      _selectedAddress = result.formattedAddress;
      _pinPosition = location;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 16),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Location Services Off'),
        content: const Text(
          'Your device location is turned off. Enable it for better accuracy, '
          'or search your delivery address manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx),
            child: const Text(
              'Search Manually',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
          TextButton(
            onPressed: () async {
              AppNavigator.pop(ctx);
              await Geolocator.openLocationSettings();
            },
            child: const Text(
              'Enable Location',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Location Permission Denied'),
        content: const Text(
          'You can still find your address using the search bar, '
          'or enable location in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx),
            child: const Text(
              'Search Manually',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
          TextButton(
            onPressed: () async {
              AppNavigator.pop(ctx);
              await Geolocator.openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String? displayAddress = _selectedAddress ?? _gpsAddress;
    final bool canConfirm = displayAddress != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() => _showDropdown = false);
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildMap(displayAddress),
              if (_locationLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              _buildSearchBar(),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: canConfirm
                      ? _buildConfirmCard(displayAddress)
                      : _buildHintCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build Helpers ─────────────────────────────────────────────────────────

  static BoxDecoration get _cardDecor => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  Widget _buildMap(String? displayAddress) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _initialPosition,
      myLocationEnabled: _locationGranted,
      myLocationButtonEnabled: _locationGranted,
      zoomControlsEnabled: false,
      onMapCreated: (c) {
        _mapController = c;
        _mapReady = true;
        if (_locationGranted) _moveToCurrentLocation();
      },
      onCameraMove: (p) => setState(() => _pinPosition = p.target),
      markers: {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _pinPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: displayAddress),
        ),
      },
    );
  }

  Widget _buildSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _circleButton(Icons.close, () => SystemNavigator.pop()),
                const SizedBox(width: 12),
                Expanded(child: _searchField()),
              ],
            ),
            if (_showDropdown && _geocodeResults.isNotEmpty) _buildDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: IconButton(icon: Icon(icon), onPressed: onTap),
  );

  Widget _searchField() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.search, color: AppColors.slate500),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _addressController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            onTap: () {
              if (_geocodeResults.isNotEmpty) {
                setState(() => _showDropdown = true);
              }
            },
            decoration: const InputDecoration(
              hintText: 'Search delivery address...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.slate400),
            ),
          ),
        ),
        if (_isSearching)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryOrange,
            ),
          )
        else if (_addressController.text.isNotEmpty)
          GestureDetector(
            onTap: () {
              _addressController.clear();
              setState(() {
                _geocodeResults = [];
                _showDropdown = false;
                _selectedAddress = null;
              });
            },
            child: const Icon(Icons.close, color: AppColors.slate400, size: 20),
          ),
      ],
    ),
  );

  Widget _buildDropdown() => Container(
    margin: const EdgeInsets.only(top: 8, left: 52),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    constraints: const BoxConstraints(maxHeight: 280),
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      itemCount: _geocodeResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (ctx, i) {
        final result = _geocodeResults[i];
        return ListTile(
          dense: true,
          leading: const Icon(
            Icons.location_on,
            size: 20,
            color: AppColors.primaryOrange,
          ),
          title: Text(
            result.formattedAddress,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _onGeocodeResultSelected(result),
        );
      },
    ),
  );

  /// Shown when a GPS/searched address exists.
  /// The subtitle is tappable and shows the location dialog when in GPS-only mode.
  Widget _buildConfirmCard(String displayAddress) {
    final bool isGpsOnly = _selectedAddress == null;
    return Container(
      key: const ValueKey('confirm'),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primaryOrange,
                ),
              ),
              AppSpaces.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      displayAddress,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // ── Tappable subtitle ──────────────────────────────────
                    // When GPS-only: tapping opens the location service dialog
                    GestureDetector(
                      onTap: isGpsOnly ? _showLocationServiceDialog : null,
                      child: AppSubText(
                        isGpsOnly
                            ? 'Or search for a specific address above'
                            : 'Tap confirm to use this address',
                        fontSize: 12,
                        color: isGpsOnly
                            ? AppColors.primaryOrange
                            : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isGpsOnly) ...[
            AppSpaces.v16,
            CustomButton(
              text: 'Confirm Location',
              backgroundColor: AppColors.primaryOrange,
              onPressed: () async {
                await ref
                    .read(sessionServiceProvider)
                    .confirmLocation(address: _selectedAddress ?? '');
                    if (!mounted) return;
             
                  AppNavigator.pushAndRemoveAll(
                    context,
                    AppRoute.dashboard,
                  
                  );
                
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Shown when no location or search selection exists.
  /// Tapping this card opens the location service dialog.
  Widget _buildHintCard() => GestureDetector(
    key: const ValueKey('hint'),
    onTap: _showLocationServiceDialog,
    child: Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: _cardDecor,
      child: const Row(
        children: [
          Icon(Icons.location_off_outlined, color: AppColors.primaryOrange),
          SizedBox(width: 12),
          Expanded(
            child: AppSubText(
              'Tap here to enable location or search above',
              fontSize: 13,
              color: AppColors.primaryOrange,
              // fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.primaryOrange,
          ),
        ],
      ),
    ),
  );
}
