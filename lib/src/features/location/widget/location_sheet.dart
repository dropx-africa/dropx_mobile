import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  final String currentAddress;
  final double currentLat;
  final double currentLng;

  const LocationPickerSheet({
    super.key,
    required this.currentAddress,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  ConsumerState<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  GoogleMapController? _mapController;

  LatLng _pinPosition = LatLng(6.5244, 3.3792);
  String? _selectedAddress;
  List<GeocodeResult> _geocodeResults = [];
  bool _isSearching = false;
  bool _showDropdown = false;
  Timer? _debounce;
  String _resolvedCity = '';
  String _resolvedState = '';

  @override
  void initState() {
    super.initState();
    _pinPosition = LatLng(widget.currentLat, widget.currentLng);
    _selectedAddress = widget.currentAddress;
    _addressController.text = widget.currentAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.isEmpty) {
      setState(() {
        _geocodeResults = [];
        _isSearching = _showDropdown = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _showDropdown = false;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await ref
            .read(placesServiceProvider)
            .autocomplete(query);
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

    // Extract city/state from the selected location
    ref.read(placesServiceProvider).extractAddressComponents(location).then(
          (comp) {
        if (mounted) {
          setState(() {
            _resolvedCity = comp.city;
            _resolvedState = comp.state;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: AppText(
                        'Change delivery address',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSearchField(),
              ),

              // Dropdown results
              if (_showDropdown && _geocodeResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: _buildDropdown(),
                ),

              // Map
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _pinPosition,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onCameraMove: (position) {
                    setState(() {
                      _pinPosition = position.target;
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _pinPosition,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  },
                ),
              ),

              // Confirm button
              if (_selectedAddress != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: AppColors.primaryOrange,
                                size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppText(
                                _selectedAddress!,
                                fontSize: 13,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // Return the new address data
                              Navigator.pop(context, {
                                'address': _selectedAddress,
                                'lat': _pinPosition.latitude,
                                'lng': _pinPosition.longitude,
                                'city': _resolvedCity,
                                'state': _resolvedState,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const AppText(
                              'Confirm address',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.slate500, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _addressController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search delivery address...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.slate400, fontSize: 14),
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
                });
              },
              child: const Icon(Icons.close, color: AppColors.slate400, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              size: 18,
              color: AppColors.primaryOrange,
            ),
            title: Text(
              result.formattedAddress,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onGeocodeResultSelected(result),
          );
        },
      ),
    );
  }
}