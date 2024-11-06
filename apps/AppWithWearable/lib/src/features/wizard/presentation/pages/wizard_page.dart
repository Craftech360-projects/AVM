import 'package:flutter/material.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/src/features/wizard/presentation/widgets/onboarding_button.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  static const name = 'OnBoardingPage';
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OnboardingButton(
            message:
                'Looks like the app needs some permission! Please enable notifications access.',
            buttonText: 'Enable',
            onSkip: _nextPage,
            onPressed: () {
              // Show permission access box
              // Navigate to next page
            },
          ),
          OnboardingButton(
            message:
                'Your personal growth journey with AI that listens to all your queries.',
            buttonText: 'Connect my AVM',
            onSkip: _nextPage,
            onPressed: () {
              // Show permission access box
              // Navigate to next page
              context.goNamed(BleConnectionPage.name);
            },
          ),
        ],
      ),
    );
  }
}
