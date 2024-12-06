import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core_updated/assets/app_images.dart';
import 'package:friend_private/core_updated/constants/constants.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';
import 'package:friend_private/src/features/wizard/presentation/bloc/wizard_bloc.dart';
import 'package:friend_private/src/features/wizard/presentation/widgets/onboarding_button.dart';

class OnboardingPage extends StatelessWidget {
  // Change to StatelessWidget
  const OnboardingPage({super.key});
  static const name = 'OnBoardingPage';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WizardBloc(context),
      child: const OnboardingPageContent(),
    );
  }
}

class OnboardingPageContent extends StatefulWidget {
  const OnboardingPageContent({super.key});

  @override
  State<OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<OnboardingPageContent> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Check if permissions are already granted
    if (SharedPreferencesUtil().notificationPermissionRequested &&
        SharedPreferencesUtil().locationPermissionRequested &&
        SharedPreferencesUtil().bluetoothPermissionRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(1); // Jump to the second page
      });
    } else {
      // Use the context from the widget tree to access WizardBloc
      context.read<WizardBloc>();
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Stack(
        children: [
          // AVM Logo positioned at 1/3 of the screen height, padded left
          Positioned(
            top: MediaQuery.of(context).size.height / 4 -
                30.h / 2, // One-third height minus half logo height
            left: 16.0, // Horizontal padding from the left
            child: Image.asset(
              AppImages.appLogo,
              height: 30.h, // Adjust the logo size as needed
            ),
          ),

          // Foreground content
          BlocListener<WizardBloc, WizardState>(
            listener: (context, state) {
              if (state is PermissionsGranted) {
                avmSnackBar(context,
                    "All permissions granted, proceeding with the app!");
                _nextPage();
              } else if (state is PermissionsDenied) {
                avmSnackBar(context, state.message);
              }
            },
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                OnboardingButton(
                  message:
                      'Looks like the app needs some permissions!\nPlease enable the necessary permissions',
                  buttonText: 'Enable',
                  onSkip: _nextPage,
                  onPressed: () {
                    context.read<WizardBloc>().add(CheckPermissionsEvent());
                  },
                ),
                OnboardingButton(
                  message:
                      'Your personal growth journey with AI that listens to all your queries.',
                  buttonText: 'Connect my AVM',
                  onSkip: _nextPage,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindDevicesPage(
                          goNext: () {},
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
