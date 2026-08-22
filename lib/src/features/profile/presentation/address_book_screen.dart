import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/core/network/api_exceptions.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/location/data/address_models.dart';
import 'package:dropx_mobile/src/features/location/widget/location_sheet.dart';

class AddressBookScreen extends ConsumerStatefulWidget {
  const AddressBookScreen({super.key});

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  List<AddressData> _addresses = const [];
  bool _isLoading = true;
  String? _busyAddressId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(addressRepositoryProvider);
      final addresses = await repo.getAddresses();
      if (mounted) setState(() => _addresses = addresses);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Could not load addresses.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(AddressData address) async {
    setState(() => _busyAddressId = address.addressId);
    try {
      await ref
          .read(addressRepositoryProvider)
          .setDefaultAddress(address.addressId);
      await _load();
      if (mounted) AppToast.showSuccess(context, '${address.label} is now your default.');
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Could not set default address.');
    } finally {
      if (mounted) setState(() => _busyAddressId = null);
    }
  }

  Future<void> _delete(AddressData address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText('Delete Address?', fontWeight: FontWeight.bold),
        content: AppText('Remove "${address.label}" from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const AppText('Cancel', color: Colors.grey),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const AppText('Delete', color: AppColors.errorRed),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busyAddressId = address.addressId);
    try {
      await ref.read(addressRepositoryProvider).deleteAddress(address.addressId);
      await _load();
      if (mounted) AppToast.showSuccess(context, 'Address deleted.');
    } on ApiException catch (e) {
      if (mounted) AppToast.showError(context, e.message);
    } catch (e) {
      if (mounted) AppToast.showError(context, 'Could not delete address.');
    } finally {
      if (mounted) setState(() => _busyAddressId = null);
    }
  }

  Future<void> _openEditSheet({AddressData? existing}) async {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final landmarkCtrl = TextEditingController(text: existing?.landmark ?? '');
    final instructionsCtrl =
        TextEditingController(text: existing?.instructions ?? '');

    // For a new address, picked via the map/search sheet below — real
    // Google-backed geocoding, not a plain text field the user has to get
    // right themselves.
    String? pickedAddress;
    double? pickedLat;
    double? pickedLng;
    String? pickedCity;
    String? pickedState;
    bool isSaving = false;

    Future<void> pickLocation(StateSetter setSheetState) async {
      final session = ref.read(sessionServiceProvider);
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LocationPickerSheet(
          currentAddress: pickedAddress ?? '',
          currentLat: pickedLat ?? session.savedLat,
          currentLng: pickedLng ?? session.savedLng,
        ),
      );
      if (result == null) return;
      setSheetState(() {
        pickedAddress = result['address'] as String?;
        pickedLat = result['lat'] as double?;
        pickedLng = result['lng'] as double?;
        pickedCity = result['city'] as String?;
        pickedState = result['state'] as String?;
      });
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    existing == null ? 'Add New Address' : 'Edit Address',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 16),
                  if (existing != null) ...[
                    _field(labelCtrl, 'Label (e.g. Home, Work)'),
                    const SizedBox(height: 12),
                  ],
                  if (existing == null) ...[
                    GestureDetector(
                      onTap: () => pickLocation(setSheetState),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: pickedAddress == null
                                ? Colors.grey.shade300
                                : AppColors.primaryOrange,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: pickedAddress == null
                                  ? Colors.grey.shade500
                                  : AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppText(
                                pickedAddress ??
                                    'Search for a delivery address',
                                fontSize: 14,
                                fontWeight: pickedAddress == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: pickedAddress == null
                                    ? AppColors.slate400
                                    : null,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppText(
                              pickedAddress == null ? 'Search' : 'Change',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryOrange,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (existing != null) ...[
                    _field(landmarkCtrl, 'Landmark (optional)'),
                    const SizedBox(height: 12),
                    _field(instructionsCtrl, 'Instructions for rider (optional)'),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (existing == null &&
                                  (pickedAddress == null ||
                                      pickedLat == null ||
                                      pickedLng == null)) {
                                AppToast.showError(
                                  ctx,
                                  'Please search and pick a delivery address.',
                                );
                                return;
                              }
                              final label = existing == null
                                  // Auto-label from the first segment of the
                                  // picked address (e.g. "Yaba Bus Park")
                                  // rather than asking for one separately.
                                  ? pickedAddress!.split(',').first.trim()
                                  : labelCtrl.text.trim();
                              if (label.isEmpty) {
                                AppToast.showError(ctx, 'Please enter a label.');
                                return;
                              }

                              setSheetState(() => isSaving = true);
                              try {
                                final repo = ref.read(addressRepositoryProvider);
                                if (existing == null) {
                                  await repo.createAddress(
                                    CreateAddressRequest(
                                      label: label,
                                      line1: pickedAddress!,
                                      city: (pickedCity ?? '').isNotEmpty
                                          ? pickedCity!
                                          : 'Lagos',
                                      state: (pickedState ?? '').isNotEmpty
                                          ? pickedState!
                                          : 'Lagos',
                                      lat: pickedLat!,
                                      lng: pickedLng!,
                                      landmark: landmarkCtrl.text.trim().isEmpty
                                          ? null
                                          : landmarkCtrl.text.trim(),
                                      instructions:
                                          instructionsCtrl.text.trim().isEmpty
                                              ? null
                                              : instructionsCtrl.text.trim(),
                                    ),
                                  );
                                } else {
                                  await repo.updateAddress(
                                    existing.addressId,
                                    label: label,
                                    landmark: landmarkCtrl.text.trim(),
                                    instructions: instructionsCtrl.text.trim(),
                                  );
                                }
                                if (ctx.mounted) Navigator.pop(ctx, true);
                              } on ApiException catch (e) {
                                setSheetState(() => isSaving = false);
                                if (ctx.mounted) AppToast.showError(ctx, e.message);
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                if (ctx.mounted) {
                                  AppToast.showError(ctx, 'Could not save address.');
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        disabledBackgroundColor:
                            AppColors.primaryOrange.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : AppText(
                              existing == null ? 'Save Address' : 'Save Changes',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      await _load();
      if (mounted) AppToast.showSuccess(context, 'Address saved.');
    }
  }

  Widget _field(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          "Address Book",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _addresses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primaryOrange,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _buildAddressCard(_addresses[i]),
                  ),
                ),
      floatingActionButton: _addresses.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primaryOrange,
              onPressed: () => _openEditSheet(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const AppText(
                'Add Address',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildAddressCard(AddressData address) {
    final busy = _busyAddressId == address.addressId;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? AppColors.primaryOrange
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    AppText(address.label, fontWeight: FontWeight.bold, fontSize: 15),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const AppText(
                          'DEFAULT',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (busy)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _openEditSheet(existing: address);
                      case 'default':
                        _setDefault(address);
                      case 'delete':
                        _delete(address);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as default'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6),
          AppText(
            address.line1,
            fontSize: 13,
            color: AppColors.slate500,
          ),
          AppText(
            '${address.city}, ${address.state}',
            fontSize: 13,
            color: AppColors.slate500,
          ),
          if (address.landmark != null && address.landmark!.isNotEmpty) ...[
            const SizedBox(height: 4),
            AppText(
              'Landmark: ${address.landmark}',
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 64,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          const AppText(
            "No Saved Addresses",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: AppText(
              "You haven't saved any delivery locations yet. Add one to make checkout faster.",
              fontSize: 15,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _openEditSheet(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const AppText(
              "Add New Address",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
