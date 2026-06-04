import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/profile/providers/social_providers.dart';
import 'package:dropx_mobile/src/features/profile/data/dto/social_dto.dart';

class ContactSyncScreen extends ConsumerStatefulWidget {
  const ContactSyncScreen({super.key});

  @override
  ConsumerState<ContactSyncScreen> createState() => _ContactSyncScreenState();
}

class _ContactSyncScreenState extends ConsumerState<ContactSyncScreen> {
  bool _contactsLoaded = false;
  bool _isLoading = false;
  bool _isSyncingAll = false;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';

  // Names of contacts that have been synced this session (shown with checkmark).
  final Set<String> _syncedContactIds = {};

  // Result from the last sync operation.
  int _totalSynced = 0;
  int _totalMatched = 0;

  Future<void> _loadContacts() async {
    debugPrint('📇 [ContactSync] _loadContacts tapped — requesting permission');
    setState(() => _isLoading = true);
    try {
      final granted = await FlutterContacts.requestPermission();
      debugPrint('📇 [ContactSync] permission granted=$granted');
      if (granted) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        debugPrint('📇 [ContactSync] loaded ${contacts.length} contacts');
        if (mounted) {
          setState(() {
            _contacts = contacts;
            _filteredContacts = contacts;
            _contactsLoaded = true;
          });
        }
      } else {
        debugPrint('📇 [ContactSync] permission denied — cannot load contacts');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('📇 [ContactSync] ❌ error loading contacts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading contacts')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncAll() async {
    final withPhone = _contacts.where((c) => c.phones.isNotEmpty).toList();
    if (withPhone.isEmpty) return;

    debugPrint('📇 [ContactSync] Sync All — ${withPhone.length} contacts with phones');
    setState(() => _isSyncingAll = true);

    try {
      final hashes = withPhone.map((c) {
        final raw = c.phones.first.number.replaceAll(RegExp(r'\s+'), '');
        return sha256.convert(utf8.encode(raw)).toString();
      }).toList();

      final dto = SyncContactsDto(hashedContacts: hashes);
      final result = await ref.read(socialRepositoryProvider).syncContacts(dto);

      if (mounted) {
        setState(() {
          for (final c in withPhone) {
            _syncedContactIds.add(c.id);
          }
          _totalSynced += result.receivedCount;
          _totalMatched += result.syncedCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.syncedCount > 0
                  ? '${result.syncedCount} of your contacts are already on DropX!'
                  : 'All ${result.receivedCount} contacts synced. None are on DropX yet.',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync contacts')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncingAll = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredContacts = query.isEmpty
          ? _contacts
          : _contacts.where((c) {
              final name = c.displayName.toLowerCase();
              final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
              return name.contains(query.toLowerCase()) || phone.contains(query);
            }).toList();
    });
  }

  Future<void> _syncSingleContact(Contact contact) async {
    if (contact.phones.isEmpty) {
      debugPrint('📇 [ContactSync] skipping "${contact.displayName}" — no phone number');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact has no phone number')),
      );
      return;
    }

    final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
    final bytes = utf8.encode(rawPhone);
    final hashedPhone = sha256.convert(bytes).toString();
    debugPrint('📇 [ContactSync] syncing "${contact.displayName}" — rawPhone=$rawPhone hash=${hashedPhone.substring(0, 8)}…');

    try {
      final dto = SyncContactsDto(hashedContacts: [hashedPhone]);
      final result = await ref.read(socialRepositoryProvider).syncContacts(dto);

      if (mounted) {
        setState(() {
          _syncedContactIds.add(contact.id);
          _totalSynced += result.receivedCount;
          _totalMatched += result.syncedCount;
        });
        final msg = result.syncedCount > 0
            ? '${contact.displayName} is on DropX!'
            : '${contact.displayName} synced — not on DropX yet';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync contact')),
        );
      }
    }
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
          'Connect Friends',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: _contactsLoaded ? _buildContactsList() : _buildPermissionView(),
    );
  }

  // ── What contact sync does ─────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primaryOrange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'How this works',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(height: 4),
                AppText(
                  'Your contacts\' phone numbers are hashed locally on your device — '
                  'raw numbers are never sent anywhere. '
                  'When a contact joins DropX with the same number, '
                  'you\'ll be matched so you can see their activity on the Social Feed.',
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                if (_totalSynced > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 14, color: AppColors.primaryOrange),
                      const SizedBox(width: 4),
                      AppText(
                        '$_totalSynced contact${_totalSynced == 1 ? '' : 's'} synced'
                        '${_totalMatched > 0 ? ' · $_totalMatched on DropX' : ''}',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Permission / load view ─────────────────────────────────────────────────

  Widget _buildPermissionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 64,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 24),
          const AppText(
            'Find Your Friends on DropX',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          AppText(
            'Sync your contacts to discover which friends are already on DropX. '
            'Only secure hashes are shared — never raw phone numbers.',
            fontSize: 14,
            color: AppColors.slate500,
            textAlign: TextAlign.center,
            height: 1.55,
          ),
     
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loadContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const AppText(
                      'Access Contacts',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contacts list ──────────────────────────────────────────────────────────

  Widget _buildContactsList() {
    final syncedCount = _syncedContactIds.length;
    final total = _contacts.where((c) => c.phones.isNotEmpty).length;

    return Column(
      children: [
        // Info card
        const SizedBox(height: 12),
        _buildInfoCard(),

        // Search + Sync All row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search contacts…',
                      hintStyle: TextStyle(color: AppColors.slate400),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.slate400),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isSyncingAll ? null : _syncAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBackground,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: _isSyncingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const AppText(
                          'Sync All',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                ),
              ),
            ],
          ),
        ),

        // Progress summary
        if (syncedCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    size: 14, color: AppColors.primaryOrange),
                const SizedBox(width: 4),
                AppText(
                  '$syncedCount of $total contacts synced this session',
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ],
            ),
          ),

        // Contact list
        Expanded(
          child: _filteredContacts.isEmpty
              ? Center(
                  child: AppText(
                    _searchQuery.isEmpty
                        ? 'No contacts found'
                        : 'No results for "$_searchQuery"',
                    color: AppColors.slate400,
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    final phone = contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : null;
                    final isSynced =
                        _syncedContactIds.contains(contact.id);
                    final name = contact.displayName.isNotEmpty
                        ? contact.displayName
                        : 'Unknown';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSynced
                              ? AppColors.primaryOrange
                                  .withValues(alpha: 0.3)
                              : AppColors.slate200,
                        ),
                      ),
                      child: ListTile(
                        onTap: phone != null && !isSynced
                            ? () => _syncSingleContact(contact)
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: isSynced
                              ? AppColors.primaryOrange
                                  .withValues(alpha: 0.15)
                              : AppColors.slate100,
                          child: AppText(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            fontWeight: FontWeight.bold,
                            color: isSynced
                                ? AppColors.primaryOrange
                                : AppColors.slate500,
                          ),
                        ),
                        title: AppText(
                          name,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        subtitle: phone != null
                            ? AppText(
                                isSynced
                                    ? 'Synced — hash stored securely'
                                    : phone,
                                fontSize: 12,
                                color: isSynced
                                    ? AppColors.primaryOrange
                                    : AppColors.slate400,
                              )
                            : const AppText(
                                'No phone number',
                                fontSize: 12,
                                color: AppColors.slate400,
                              ),
                        trailing: isSynced
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primaryOrange)
                            : phone != null
                                ? TextButton(
                                    onPressed: () =>
                                        _syncSingleContact(contact),
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryOrange
                                              .withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const AppText(
                                      'Sync',
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  )
                                : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
