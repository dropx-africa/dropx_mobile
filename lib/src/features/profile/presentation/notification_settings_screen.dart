import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/profile/providers/preferences_provider.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_preferences_dto.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool? _pushEnabled;
  bool? _emailEnabled;
  bool? _smsEnabled;
  bool? _orderUpdates;
  bool? _promotions;
  bool? _systemAlerts;
  bool? _optInMarketing;
  bool? _showFriends;

  void _update(UpdatePreferencesDto dto) {
    ref.read(preferencesNotifierProvider.notifier).updatePreferences(dto);
  }

  @override
  Widget build(BuildContext context) {
    final prefsState = ref.watch(preferencesNotifierProvider);
    final prefs = prefsState.value;

    final pushEnabled   = _pushEnabled   ?? prefs?.pushEnabled          ?? true;
    final emailEnabled  = _emailEnabled  ?? prefs?.emailEnabled         ?? true;
    final smsEnabled    = _smsEnabled    ?? prefs?.smsEnabled           ?? true;
    final orderUpdates  = _orderUpdates  ?? prefs?.orderUpdatesEnabled  ?? true;
    final promotions    = _promotions    ?? prefs?.promotionsEnabled     ?? false;
    final systemAlerts  = _systemAlerts  ?? prefs?.systemAlertsEnabled  ?? true;
    final marketing     = _optInMarketing ?? prefs?.marketingOptIn      ?? false;
    final showFriends   = _showFriends   ?? prefs?.showOrdersToFriends  ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const AppText(
          "Notifications",
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: prefsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Channels"),
                  _buildSettingsCard(
                    children: [
                      _buildToggleRow(
                        icon: Icons.notifications_active_outlined,
                        title: "Push Notifications",
                        subtitle: "Receive alerts on your device",
                        value: pushEnabled,
                        showDivider: true,
                        onChanged: (val) {
                          setState(() => _pushEnabled = val);
                          _update(UpdatePreferencesDto(pushEnabled: val));
                        },
                      ),
                      _buildToggleRow(
                        icon: Icons.email_outlined,
                        title: "Email Notifications",
                        subtitle: "Receive updates via email",
                        value: emailEnabled,
                        showDivider: true,
                        onChanged: (val) {
                          setState(() => _emailEnabled = val);
                          _update(UpdatePreferencesDto(emailEnabled: val));
                        },
                      ),
                      _buildToggleRow(
                        icon: Icons.sms_outlined,
                        title: "SMS Notifications",
                        subtitle: "Receive text message alerts",
                        value: smsEnabled,
                        onChanged: (val) {
                          setState(() => _smsEnabled = val);
                          _update(UpdatePreferencesDto(smsEnabled: val));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Alert Types"),
                  _buildSettingsCard(
                    children: [
                      _buildToggleRow(
                        icon: Icons.local_shipping_outlined,
                        title: "Order Updates",
                        subtitle: "Status changes, delivery alerts",
                        value: orderUpdates,
                        showDivider: true,
                        onChanged: (val) {
                          setState(() => _orderUpdates = val);
                          _update(UpdatePreferencesDto(orderUpdatesEnabled: val));
                        },
                      ),
                      _buildToggleRow(
                        icon: Icons.local_offer_outlined,
                        title: "Promotions",
                        subtitle: "Deals, discounts, and offers",
                        value: promotions,
                        showDivider: true,
                        onChanged: (val) {
                          setState(() => _promotions = val);
                          _update(UpdatePreferencesDto(promotionsEnabled: val));
                        },
                      ),
                      _buildToggleRow(
                        icon: Icons.warning_amber_outlined,
                        title: "System Alerts",
                        subtitle: "Service notices and important updates",
                        value: systemAlerts,
                        onChanged: (val) {
                          setState(() => _systemAlerts = val);
                          _update(UpdatePreferencesDto(systemAlertsEnabled: val));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Account & Privacy"),
                  _buildSettingsCard(
                    children: [
                      _buildToggleRow(
                        icon: Icons.campaign_outlined,
                        title: "Marketing Opt-in",
                        subtitle: "Personalised offers from DropX",
                        value: marketing,
                        showDivider: true,
                        onChanged: (val) {
                          setState(() => _optInMarketing = val);
                          _update(UpdatePreferencesDto(marketingOptIn: val));
                        },
                      ),
                      _buildToggleRow(
                        icon: Icons.group_outlined,
                        title: "Share Orders with Friends",
                        subtitle: "Let friends see what you're ordering",
                        value: showFriends,
                        onChanged: (val) {
                          setState(() => _showFriends = val);
                          _update(UpdatePreferencesDto(showOrdersToFriends: val));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: AppText(
        title.toUpperCase(),
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.slate500,
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.darkBackground, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontWeight: FontWeight.w600, fontSize: 16),
                    const SizedBox(height: 2),
                    AppText(subtitle, fontSize: 13, color: AppColors.slate400),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.primaryOrange,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 56, color: AppColors.slate100),
      ],
    );
  }
}
