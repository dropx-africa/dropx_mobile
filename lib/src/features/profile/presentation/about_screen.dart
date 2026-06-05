import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/utils/app_navigator.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
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
          'About DropX',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + identity
            Center(
              child: Column(
                children: [
                  AppImage(
                    AppIcon.logo2,
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 12),
                  const AppText(
                    'DropX',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 6),
                  const AppText(
                    'Food, essentials, parcels, and local delivery in one app.',
                    fontSize: 14,
                    color: AppColors.slate500,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About copy
            _buildCard(
              children: [
                _buildBodyText(
                  'DropX connects customers with nearby vendors and riders so everyday '
                  'deliveries are easier to request, track, and complete. You can order '
                  'from local businesses, send parcels, pay securely, and follow each '
                  'delivery from checkout to handoff.',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // What you can do
            _buildSectionHeader('What you can do with DropX'),
            _buildCard(
              children: [
                _buildBullet('Browse nearby stores and products'),
                _buildBullet('Place food, grocery, and retail orders'),
                _buildBullet('Send parcels with pickup and dropoff details'),
                _buildBullet('Track active orders and parcel deliveries'),
                _buildBullet('Pay with DropX Wallet or Paystack'),
                _buildBullet('Get SMS, email, push, and in-app updates'),
                _buildBullet('Contact support when you need help'),
              ],
            ),
            const SizedBox(height: 16),

            // Trust and safety
            _buildSectionHeader('Trust and safety'),
            _buildCard(
              children: [
                _buildBodyText(
                  'DropX uses verified handoff flows, delivery codes, pickup PINs, '
                  'payment records, and notification history to keep deliveries '
                  'traceable and support-ready.',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Need help
            _buildSectionHeader('Need help?'),
            _buildCard(
              children: [
                _buildBodyText(
                  'Contact support from the app and include your order ID or parcel ID '
                  'for faster assistance.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        AppNavigator.push(context, AppRoute.supportTickets),
                    icon: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.primaryOrange,
                    ),
                    label: const AppText(
                      'Contact Support',
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Legal links
            _buildSectionHeader('Legal'),
            _buildCard(
              children: [
                _buildLinkRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Notice',
                  onTap: () => AppNavigator.push(context, AppRoute.privacy),
                ),
                const Divider(height: 1, indent: 16, color: AppColors.slate100),
                _buildLinkRow(
                  icon: Icons.description_outlined,
                  label: 'Terms of Use',
                  onTap: () => AppNavigator.push(context, AppRoute.terms),
                ),
                const Divider(height: 1, indent: 16, color: AppColors.slate100),
                _buildLinkRow(
                  icon: Icons.article_outlined,
                  label: 'Open Source Licences',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'DropX',
                    applicationVersion: _version,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Version footer
            Center(
              child: Column(
                children: [
                  const AppText(
                    'DropX Africa',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _version.isNotEmpty
                        ? 'Version $_version (Build $_buildNumber)'
                        : '',
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: AppText(
          title.toUpperCase(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: AppColors.slate500,
        ),
      );

  Widget _buildCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _buildBodyText(String text) => AppText(
        text,
        fontSize: 14,
        color: AppColors.slate500,
        height: 1.55,
      );

  Widget _buildBullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText('• ', fontSize: 14, color: AppColors.primaryOrange),
            Expanded(
              child: AppText(text, fontSize: 14, color: AppColors.slate500),
            ),
          ],
        ),
      );

  Widget _buildLinkRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.slate500),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  label,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.slate400,
              ),
            ],
          ),
        ),
      );
}
