import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/assets/app_images.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/widgets/custom_dialog_box.dart';
import 'package:capsoul/features/wizard/bloc/wizard_bloc.dart';
import 'package:capsoul/features/wizard/widgets/onboarding_button.dart';
import 'package:capsoul/pages/home/custom_scaffold.dart';
import 'package:capsoul/pages/onboarding/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        _pageController.jumpToPage(1);
      });
    } else {
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
          // height: MediaQuery.of(context).size.height * 0.6,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                            'Hey, you can backup all the memories\nin cloud! Give us the permission\nto auto-backup your memories',
                        buttonText: 'Enable',
                        onSkip: _nextPage,
                        onPressed: () async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogWidget(
                                title: "Enable Memory Backup",
                                message:
                                    "Backup your memories automatically to Google cloud! Enable the permissions to auto-backup",
                                icon: Icons.backup_rounded,
                                noText: "Not now",
                                yesText: "Enable",
                                yesPressed: () {
                                  SharedPreferencesUtil().backupsEnabled = true;
                                  avmSnackBar(context,
                                      "Auto-memory backup is active now");
                                  _nextPage();
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        }),
                    OnboardingButton(
                      message:
                          'Your personal growth journey\nwith AI that listens to\nall your queries',
                      buttonText: 'Connect my Capsoul',
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
