import 'package:dropx_mobile/src/core/models/client_config.dart';
import 'package:dropx_mobile/src/core/providers/client_config_provider.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/common_widgets/maintenance_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/features/auth/data/dto/update_preferences_dto.dart';
import 'package:dropx_mobile/src/features/home/presentation/home_tab.dart';
import 'package:dropx_mobile/src/features/order/presentation/orders_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/profile_screen.dart';
import 'package:dropx_mobile/src/features/profile/providers/preferences_provider.dart';
import 'package:dropx_mobile/src/features/discover/presentation/discover_screen.dart';
import 'package:dropx_mobile/src/features/wallet/presentation/wallet_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const DashboardScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  late int _currentIndex = widget.initialTab;

  late final Set<int> _visited = {widget.initialTab};

  // null = not yet checked; true = granted; false = denied
  bool? _notificationsGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Kick off client config fetch as soon as the dashboard mounts.
      ref.read(clientConfigProvider);

      final session = ref.read(sessionServiceProvider);
      if (!session.isLoggedIn) return;
      final granted = await ref.read(pushTokenServiceProvider).initialize();
      if (mounted) setState(() => _notificationsGranted = granted);
      final currentPrefs = ref.read(preferencesNotifierProvider).valueOrNull;
      if (currentPrefs?.pushEnabled != granted) {
        try {
          await ref
              .read(preferencesNotifierProvider.notifier)
              .updatePreferences(UpdatePreferencesDto(pushEnabled: granted));
        } catch (_) {
          // Non-fatal — preference sync must never break the dashboard.
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check notification permission in case user toggled it in Settings.
      if (_notificationsGranted == false) _recheckNotificationPermission();
      // Re-fetch config so maintenance mode resolves when backend comes back.
      ref.read(clientConfigProvider.notifier).refresh();
    }
  }

  Future<void> _recheckNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (mounted) setState(() => _notificationsGranted = granted);
  }

  static const List<Widget> _tabs = [
    HomeTab(),
    DiscoverScreen(),
    OrdersScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    final isGuest = ref.read(sessionServiceProvider).isGuest;
    if (isGuest && (index == 2 || index == 3 || index == 4)) {
      _showSignUpSheet();
      return;
    }
    setState(() {
      _visited.add(index);
      _currentIndex = index;
    });
  }

  void _showSignUpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignUpToOrderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(clientConfigProvider);
    final config = configAsync.valueOrNull ?? ClientConfig.defaults;

    // Full maintenance — replace the entire dashboard with the maintenance page.
    if (config.isFullMaintenance) {
      return const MaintenanceScreen();
    }

    final showNotifBanner = _notificationsGranted == false;
    final showDegradedBanner = config.isDegraded || config.isReadOnly;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: Column(
          children: [
            if (showDegradedBanner) _buildDegradedBanner(config),
            if (showNotifBanner) _buildNotificationBanner(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: List.generate(
                  _tabs.length,
                  (i) => _visited.contains(i) ? _tabs[i] : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryOrange,
          unselectedItemColor: AppColors.slate400,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDegradedBanner(ClientConfig config) {
    final isReadOnly = config.isReadOnly;
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: isReadOnly ? Colors.orange.shade700 : Colors.amber.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isReadOnly ? Icons.edit_off_outlined : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                isReadOnly
                    ? 'Some features are temporarily unavailable. Browsing only.'
                    : 'Some services are experiencing issues. We\'re working on it.',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.notifications_off_outlined,
                color: Colors.white70, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: AppText(
                'Enable notifications to track your orders in real time.',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: openAppSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const AppText(
                  'Enable',
                  fontSize: 12,
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
}
