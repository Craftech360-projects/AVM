import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/features/wizard/bloc/wizard_bloc.dart';
import 'package:avm/features/wizard/widgets/onboarding_button.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/onboarding/find_device/page.dart';

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
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  AppImages.appLogo,
                  height: 30.h,
                ),
              ),
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
                          'Looks like the app needs\nsome permissions! Please\nenable necesssary permissions',
                      buttonText: 'Enable',
                      onSkip: _nextPage,
                      onPressed: () {
                        context.read<WizardBloc>().add(CheckPermissionsEvent());
                      },
                    ),
                    OnboardingButton(
                      message:
                          'Your personal growth journey\nwith AI that listens to\nall your queries',
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
        ),
      ),
    );
  }
}
