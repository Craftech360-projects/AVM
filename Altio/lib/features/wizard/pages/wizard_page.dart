import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/wizard/bloc/wizard_bloc.dart';
import 'package:altio/features/wizard/widgets/onboarding_button.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/pages/home/page.dart';
import 'package:altio/pages/onboarding/page.dart';
import 'package:altio/utils/features/backups.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPage extends StatelessWidget {
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
  bool isTOSAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkTosStatus();
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

  Future<void> _checkTosStatus() async {
    final bool tosAccepted = SharedPreferencesUtil().tosAccepted;
    isTOSAccepted = tosAccepted;
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
      body: _isLoading
          ? Center(
              child: Column(
                children: [
                  TypingIndicator(),
                  h8,
                  Text("Backup is in progress...\nPlease wait"),
                ],
              ),
            )
          : Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height * 0.6,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                              context
                                  .read<WizardBloc>()
                                  .add(CheckPermissionsEvent());
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
                                      noPressed: () {
                                        _nextPage();
                                        Navigator.pop(context);
                                      },
                                      yesPressed: () async {
                                        _isLoading = true;
                                        SharedPreferencesUtil().backupsEnabled =
                                            true;
                                        await retrieveBackup(
                                            SharedPreferencesUtil().uid);
                                        avmSnackBar(context,
                                            "Auto-memory backup is active now");
                                        _nextPage();
                                        _isLoading = false;
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              }),
                          OnboardingButton(
                            message:
                                'Your personal growth journey\nwith AI that listens to\nall your queries',
                            buttonText: 'Connect my Capsaul',
                            onSkip: () async {
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await DeviceFlagService().setDeviceFlag(
                                      uid: user.uid, hasDevice: false);
                                }
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePageWrapper(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                avmSnackBar(context, e.toString());
                              }
                            },
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FindDevicesPage(
                                    goNext: () {},
                                  ),
                                ),
                                (route) => false,
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
