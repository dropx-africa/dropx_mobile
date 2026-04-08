import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/location/data/geocode_result.dart';

/// Full-screen address picker for parcel pickup / dropoff.
/// Push this screen and await the result — it pops with a [GeocodeResult]
/// when the user confirms, or null if they cancel.
class ParcelAddressPickerScreen extends ConsumerStatefulWidget {
  final String title;

  const ParcelAddressPickerScreen({super.key, required this.title});

  @override
  ConsumerState<ParcelAddressPickerScreen> createState() =>
      _ParcelAddressPickerScreenState();
}

class _ParcelAddressPickerScreenState
    extends ConsumerState<ParcelAddressPickerScreen> {
  static const LatLng _lagosDefault = LatLng(6.5244, 3.3792);

  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  GoogleMapController? _mapController;
  LatLng _pin = _lagosDefault;

  Timer? _debounce;
  List<GeocodeResult> _suggestions = [];
  bool _isSearching = false;
  bool _showDropdown = false;
  GeocodeResult? _selected;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
        _showDropdown = false;
        _selected = null;
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _showDropdown = false;
      _selected = null;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results =
          await ref.read(placesServiceProvider).autocomplete(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
        _showDropdown = results.isNotEmpty;
      });
    });
  }

  void _onResultSelected(GeocodeResult result) {
    _searchCtrl.text = result.formattedAddress;
    _focusNode.unfocus();
    final loc = LatLng(result.lat, result.lng);
    setState(() {
      _selected = result;
      _pin = loc;
      _suggestions = [];
      _showDropdown = false;
      _isSearching = false;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: loc, zoom: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        setState(() => _showDropdown = false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Map ────────────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _lagosDefault,
                zoom: 13,
              ),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (c) => _mapController = c,
              markers: {
                Marker(
                  markerId: const MarkerId('pin'),
                  position: _pin,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                ),
              },
            ),

            // ── Search bar overlay ────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      children: [
                        _circleButton(
                          Icons.arrow_back,
                          () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        AppText(
                          widget.title,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.slate500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _focusNode,
                              onChanged: _onSearchChanged,
                              decoration: const InputDecoration(
                                hintText: 'Search address in Lagos...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.slate400),
                              ),
                            ),
                          ),
                          if (_isSearching)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryOrange,
                              ),
                            )
                          else if (_searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _suggestions = [];
                                  _showDropdown = false;
                                  _selected = null;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: AppColors.slate400,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Suggestions dropdown
                    if (_showDropdown && _suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 16),
                          itemBuilder: (_, i) {
                            final r = _suggestions[i];
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.location_on,
                                size: 20,
                                color: AppColors.primaryOrange,
                              ),
                              title: Text(
                                r.formattedAddress,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _onResultSelected(r),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Confirm card (bottom) ──────────────────────────────────────
            if (_selected != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -4),
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
                              color: AppColors.primaryOrange.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              _selected!.formattedAddress,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, _selected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const AppText(
                            'Confirm Location',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
}
