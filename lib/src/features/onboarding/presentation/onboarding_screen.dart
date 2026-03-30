import 'package:dropx_mobile/src/utils/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_scaffold.dart';
import 'package:dropx_mobile/src/route/page.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

const _pages = [
  _OnboardingPage(
    title: 'Order in Seconds',
    description:
        'Browse restaurants and shops near you. Your favourite food and essentials, delivered fast.',
    icon: Icons.storefront_rounded,
    bgColor: Color(0xFFFFF3EC),
    iconColor: AppColors.primaryOrange,
  ),
  _OnboardingPage(
    title: 'Track Your Rider Live',
    description:
        'Follow your delivery in real-time on the map — from kitchen to your doorstep.',
    icon: Icons.location_on_rounded,
    bgColor: Color(0xFFEDF6FF),
    iconColor: Color(0xFF1A73E8),
  ),
  _OnboardingPage(
    title: 'Pay Securely',
    description:
        'Pay with cards or wallet. Every transaction is encrypted and fully protected.',
    icon: Icons.shield_rounded,
    bgColor: Color(0xFFEFFAF3),
    iconColor: Color(0xFF27AE60),
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finish() async {
    await ref.read(sessionServiceProvider).markOnboardingDone();
    if (mounted) AppNavigator.pushReplacement(context, AppRoute.login);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return AppScaffold(
      backgroundColor: Colors.white,
      useSafeArea: false,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: SafeArea(
            child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.slate500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _PageContent(page: _pages[i]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 6),
                  height: 6,
                  width: _currentPage == i ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.primaryOrange
                        : AppColors.slate200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Primary CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // "Already have an account" link — only on first page
            AnimatedOpacity(
              opacity: _currentPage == 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: _currentPage == 0 ? _finish : null,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: AppColors.slate500, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ],
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: page.iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 60, color: page.iconColor),
              ),
            ),
          ),

          const SizedBox(height: 48),

          AppHeader(page.title, textAlign: TextAlign.center),

          const SizedBox(height: 16),

          AppSubText(
            page.description,
            textAlign: TextAlign.center,
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
