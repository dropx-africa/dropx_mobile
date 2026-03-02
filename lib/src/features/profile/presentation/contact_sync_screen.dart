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
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  final Set<String> _syncedContactIds =
      {}; // to keep track of added contacts locally

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
        );
        if (mounted) {
          setState(() {
            _contacts = contacts;
            _filteredContacts = contacts;
            _contactsLoaded = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission denied')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error loading contacts')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((c) {
          final name = c.displayName.toLowerCase();
          final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _syncSingleContact(Contact contact) async {
    if (contact.phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact has no phone number')),
      );
      return;
    }

    // Prepare phone before hashing (remove spaces, etc.)
    final rawPhone = contact.phones.first.number.replaceAll(RegExp(r'\s+'), '');
    final bytes = utf8.encode(rawPhone);
    final hashedPhone = sha256.convert(bytes).toString();

    try {
      // We pass the hashed phone to the backend
      final dto = SyncContactsDto(hashedContacts: [hashedPhone]);
      await ref.read(socialRepositoryProvider).syncContacts(dto);

      if (mounted) {
        setState(() {
          _syncedContactIds.add(contact.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully synced ${contact.displayName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to sync contact')));
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
          "Connect Friends",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: _contactsLoaded ? _buildContactsList() : _buildPermissionView(),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                Icons.people_alt_rounded,
                size: 64,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            const AppText(
              "Find Your Friends",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const AppText(
              "Let us access your contacts so you can search and pick friends to invite to DropX.",
              fontSize: 15,
              color: AppColors.slate500,
              textAlign: TextAlign.center,
              height: 1.5,
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
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const AppText(
                        "Load Contacts",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate200),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search friends...',
                hintStyle: TextStyle(color: AppColors.slate400),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.slate400),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              final phone = contact.phones.isNotEmpty
                  ? contact.phones.first.number
                  : 'No phone';
              final isSynced = _syncedContactIds.contains(contact.id);
              final name = contact.displayName.isNotEmpty
                  ? contact.displayName
                  : 'Unknown';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: ListTile(
                  onTap: () {
                    if (!isSynced) {
                      _syncSingleContact(contact);
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.slate100,
                    child: AppText(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      fontWeight: FontWeight.bold,
                      color: AppColors.slate500,
                    ),
                  ),
                  title: AppText(
                    name,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  subtitle: AppText(
                    phone,
                    fontSize: 13,
                    color: AppColors.slate400,
                  ),
                  trailing: isSynced
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.successGreen,
                        )
                      : TextButton(
                          onPressed: () => _syncSingleContact(contact),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange.withValues(
                              alpha: 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const AppText(
                            "Sync",
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
