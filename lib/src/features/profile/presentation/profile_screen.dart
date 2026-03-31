import 'package:dropx_mobile/src/common_widgets/app_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/core/network/api_client.dart';
import 'package:dropx_mobile/src/features/auth/providers/auth_providers.dart';
import 'package:dropx_mobile/src/features/profile/presentation/preferences_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/notification_settings_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/contact_sync_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/support_tickets_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/social_feed_screen.dart';
import 'package:dropx_mobile/src/features/profile/presentation/edit_profile_screen.dart';
import 'package:dropx_mobile/src/features/profile/providers/profile_provider.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:dropx_mobile/src/common_widgets/app_toast.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final userProfile = profileState.value?.profile;

    final displayName = userProfile?.fullName ?? 'User';
    final displayPhone = userProfile?.phone ?? '—';

    return AppScaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppAppBar(title: 'Profile', showBack: false),
      children: [
        // User Header
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7A00), Color(0xFFFF9D42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: userProfile?.avatarUrl != null
                      ? NetworkImage(userProfile!.avatarUrl!)
                      : null,
                  child: userProfile?.avatarUrl == null
                      ? AppText(
                          _getInitials(displayName),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      displayName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      displayPhone,
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                onPressed: () {
                  AppNavigator.push(context, AppRoute.editProfile);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const AppText(
          "CONNECT",
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.slate500,
        ),
        const SizedBox(height: 12),
        _buildProfileOption(
          icon: Icons.groups_rounded,
          title: "Connect with Friends",
          subtitle: "Sync contacts & invite",
          onTap: () {
            AppNavigator.push(context, AppRoute.contactSync);
          },
        ),
        _buildProfileOption(
          icon: Icons.dynamic_feed_rounded,
          title: "Social Feed",
          subtitle: "See what friends are ordering",
          onTap: () {
            AppNavigator.push(context, AppRoute.socialFeed);
          },
        ),

        const SizedBox(height: 24),
        const AppText(
          "ACCOUNT",
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.slate500,
        ),

        const SizedBox(height: 12),
        _buildProfileOption(
          icon: Icons.settings_rounded,
          title: "Preferences",
          subtitle: "Language, Theme, Currency",
          onTap: () {
            AppNavigator.push(context, AppRoute.preferences);
          },
        ),
        _buildProfileOption(
          icon: Icons.notifications_active_rounded,
          title: "Notifications",
          subtitle: "Push, Email, SMS",
          onTap: () {
            AppNavigator.push(context, AppRoute.notificationSettings);
          },
        ),
        const SizedBox(height: 24),
        const AppText(
          "SUPPORT",
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.slate500,
        ),
        const SizedBox(height: 12),

        _buildProfileOption(
          icon: Icons.support_agent_rounded,
          title: "Help & Support Tickets",
          subtitle: "View active and past issues",
          onTap: () {
            AppNavigator.push(context, AppRoute.supportTickets);
          },
        ),
        _buildProfileOption(
          icon: Icons.info_outline_rounded,
          title: "About DropX",
          onTap: () {},
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showLogoutConfirmation(context, ref),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
            label: const AppText(
              "Log Out",
              color: AppColors.errorRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AppText(
          "Log Out",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        content: const AppText(
          "Are you sure you want to log out of your account?",
          fontSize: 15,
          color: AppColors.slate500,
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => AppNavigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const AppText(
              "Cancel",
              color: AppColors.slate500,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              AppNavigator.pop(ctx);
              final session = ref.read(sessionServiceProvider);
              final refreshToken = session.refreshToken;

              if (refreshToken != null) {
                try {
                  await ref
                      .read(authRepositoryProvider)
                      .logout(refreshToken, allDevices: false);
                } catch (e) {
                  debugPrint('Logout API failed: $e');
                }
              }

              await session.clearSession();
              ApiClient().clearAuthToken();
              if (context.mounted) {
                AppNavigator.pushAndRemoveAll(context, AppRoute.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const AppText(
              "Log Out",
              color: Colors.white,
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
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryOrange, size: 22),
        ),
        title: AppText(title, fontWeight: FontWeight.w600, fontSize: 16),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.slate400,
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.slate50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.slate400,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'User') return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    } else {
      return parts[0][0].toUpperCase();
    }
  }
}
