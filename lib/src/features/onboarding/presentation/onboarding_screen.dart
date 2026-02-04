import 'package:flutter/material.dart';
import 'package:dropx_mobile/src/constants/app_colors.dart';
import 'package:dropx_mobile/src/constants/app_icons.dart';
import 'package:dropx_mobile/src/common_widgets/app_text.dart';
import 'package:dropx_mobile/src/common_widgets/app_spacers.dart';
import 'package:dropx_mobile/src/common_widgets/app_image.dart';
import 'package:dropx_mobile/src/common_widgets/custom_button.dart';
import 'package:dropx_mobile/src/route/page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Fast & Reliable Delivery",
      "description":
          "Experience the quickest way to send and receive packages across the city with DropX.",
      "image": AppIcon.onboarding1,
    },
    {
      "title": "Real-Time Tracking",
      "description":
          "Track your package in real-time and get notified at every step of the delivery.",
      "image": AppIcon.onboarding2,
    },
    {
      "title": "Secure Payments",
      "description":
          "Pay securely with multiple payment options available in the app.",
      "image": AppIcon.onboarding3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  // TODO: Navigate to help/support
                },
                icon: const Icon(
                  Icons.help_outline,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  description: _onboardingData[index]["description"]!,
                  image: _onboardingData[index]["image"]!,
                ),
              ),
            ),
            AppSpaces.v20,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => buildDot(index: index),
              ),
            ),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                text: _currentPage == _onboardingData.length - 1
                    ? "Get Started"
                    : "Next",
                backgroundColor: AppColors.primaryOrange,
                textColor: AppColors.white,
                icon: const Icon(Icons.arrow_forward, color: AppColors.white),
                onPressed: () {
                  if (_currentPage == _onboardingData.length - 1) {
                    Navigator.pushReplacementNamed(context, AppRoute.login);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
              ),
            ),

            AppSpaces.v20,

            if (_currentPage == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: CustomButton(
                  text: "I already have an account",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoute.login);
                  },
                  backgroundColor: Colors.transparent,
                  textColor: AppColors.darkBackground,
                  borderColor: AppColors.slate200,
                ),
              ),
            AppSpaces.v20,
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primaryOrange
            : AppColors.slate200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, description, image;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppImage(image, fit: BoxFit.contain),
            ),
          ),
        ),
        AppSpaces.v20,
        AppHeader(title, textAlign: TextAlign.center),
        AppSpaces.v10,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AppSubText(
            description,
            textAlign: TextAlign.center,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
