import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionServiceProvider);
    final displayName = session.fullName.isNotEmpty ? session.fullName : 'User';
    final displayPhone = session.phone.isNotEmpty ? session.phone : '—';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                "Profile",
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 24),
              // User Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryOrange.withValues(
                        alpha: 0.15,
                      ),
                      child: AppText(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            displayName,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            displayPhone,
                            fontSize: 14,
                            color: AppColors.slate400,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primaryOrange,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const AppText(
                "Account",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate500,
              ),

              const SizedBox(height: 12),
              _buildProfileOption(
                icon: Icons.group_add_outlined,
                title: "Connect with Friends",
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.card_membership_outlined,
                title: "Subscriptions",
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.account_balance_wallet_outlined,
                title: "Payment Methods",
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.location_on_outlined,
                title: "Address Book",
                onTap: () {},
              ),

              const SizedBox(height: 24),
              const AppText(
                "General",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.slate500,
              ),
              const SizedBox(height: 12),

              _buildProfileOption(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: "About App",
                onTap: () {},
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showLogoutConfirmation(context, ref),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const AppText(
                    "Log Out",
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const AppText(
          "Log Out",
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        content: const AppText(
          "Are you sure you want to log out?",
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const AppText("Cancel", color: AppColors.slate400),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(sessionServiceProvider).clearSession();
              ApiClient().clearAuthToken();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoute.login, (route) => false);
              }
            },
            child: const AppText(
              "Log Out",
              color: AppColors.errorRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.darkBackground, size: 20),
        ),
        title: AppText(title, fontWeight: FontWeight.w600),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.slate400,
        ),
      ),
    );
  }
}
