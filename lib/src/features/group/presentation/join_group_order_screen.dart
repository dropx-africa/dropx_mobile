import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_loading_widget.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/group/providers/group_order_providers.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class JoinGroupOrderScreen extends ConsumerStatefulWidget {
  final String inviteToken;

  const JoinGroupOrderScreen({super.key, required this.inviteToken});

  @override
  ConsumerState<JoinGroupOrderScreen> createState() =>
      _JoinGroupOrderScreenState();
}

class _JoinGroupOrderScreenState
    extends ConsumerState<JoinGroupOrderScreen> {
  final _nameController = TextEditingController();
  bool _isJoining = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final result = await ref
          .read(groupOrderRepositoryProvider)
          .joinGroupOrder(widget.inviteToken, name);

      // After joining, fetch the room details to get vendorId
      final room = await ref
          .read(groupOrderRepositoryProvider)
          .getGroupOrder(result.groupOrderId, result.participantToken);

      // Save session with vendorId from the room
      ref.read(groupOrderSessionProvider.notifier).state = GroupOrderSession(
        groupOrderId: result.groupOrderId,
        participantToken: result.participantToken,
        isHost: false,
        vendorId: room.vendorId, // Get from fetched room
      );

      if (!mounted) return;
      AppNavigator.pushReplacement(context, AppRoute.groupOrder);
    } catch (e) {
      setState(() {
        _error = 'Could not join. The link may have expired.';
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewAsync =
    ref.watch(groupOrderInviteProvider(widget.inviteToken));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: previewAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 56, color: AppColors.slate200),
                const SizedBox(height: 16),
                const AppText(
                  'Invite not found',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                AppText(
                  'This invite link may have expired or already been used.',
                  color: AppColors.slate400,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ),
        data: (preview) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AppText(
                        'Group order',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      preview.vendorName,
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      '${preview.participantCount} '
                          '${preview.participantCount == 1 ? 'person' : 'people'} have joined',
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const AppText(
                'What should we call you?',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 6),
              AppText(
                'Your name will be shown next to the items you add.',
                color: AppColors.slate400,
                fontSize: 13,
              ),
              const SizedBox(height: 20),

              // ── Name input ────────────────────────────────────────────
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle:
                  const TextStyle(color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  errorText: _error,
                ),
                onSubmitted: (_) => _join(),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isJoining ? null : _join,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    disabledBackgroundColor: AppColors.slate200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: _isJoining
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const AppText(
                    'Join and add items',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}