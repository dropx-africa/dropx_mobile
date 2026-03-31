import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/features/home/presentation/home_tab.dart';
import 'package:dropx_mobile/src/features/order/presentation/orders_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/profile_screen.dart';
import 'package:dropx_mobile/src/features/discover/presentation/discover_screen.dart';
import 'package:dropx_mobile/src/features/wallet/presentation/wallet_screen.dart';
import 'package:dropx_mobile/src/features/auth/presentation/sign_up_to_order_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const DashboardScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int _currentIndex = widget.initialTab;

  // Tracks which tabs have been visited (and therefore built) at least once.
  // Only the initial tab is marked as visited on startup.
  late final Set<int> _visited = {widget.initialTab};

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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _tabs.length,
          (i) => _visited.contains(i) ? _tabs[i] : const SizedBox.shrink(),
        ),
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
    );
  }
}
