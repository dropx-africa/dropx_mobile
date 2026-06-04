import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/core/models/client_config.dart';
import 'package:dropx_mobile/src/core/providers/client_config_provider.dart';

/// Full-screen maintenance page shown when `maintenance.mode == 'maintenance'`.
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(clientConfigProvider);
    final config = configAsync.valueOrNull ?? ClientConfig.defaults;

    final message = config.maintenanceMessage.isNotEmpty
        ? config.maintenanceMessage
        : 'We\'re currently performing maintenance to improve your experience. Please check back shortly.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.build_outlined,
                  size: 44,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 28),
              const AppText(
                'Under Maintenance',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              AppText(
                message,
                fontSize: 14,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
                height: 1.6,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(clientConfigProvider.notifier).refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const AppText(
                    'Try Again',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (config.maintenanceSupportUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    final uri = Uri.tryParse(config.maintenanceSupportUrl);
                    if (uri != null) launchUrl(uri);
                  },
                  child: AppText(
                    'Contact Support',
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
