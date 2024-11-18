import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/utils/permissions/PermissionsService.dart';
import 'package:friend_private/src/features/wizard/presentation/bloc/wizard_bloc.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/src/features/wizard/presentation/widgets/onboarding_button.dart';
import 'package:go_router/go_router.dart';
import 'package:friend_private/backend/preferences.dart';

class OnboardingPage extends StatelessWidget {
  // Change to StatelessWidget
  const OnboardingPage({super.key});
  static const name = 'OnBoardingPage';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WizardBloc(context),
      child: OnboardingPageContent(), // Extract to a separate widget
    );
  }
}

class OnboardingPageContent extends StatefulWidget {
  const OnboardingPageContent({Key? key}) : super(key: key);

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
      body: BlocListener<WizardBloc, WizardState>(
        listener: (context, state) {
          if (state is PermissionsGranted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('All permissions granted, proceeding with the app!'),
            ));
            _nextPage();
          } else if (state is PermissionsDenied) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
            ));
          }
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            OnboardingButton(
              message:
                  'Looks like the app needs some permission! Please enable notifications access.',
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
                // context.goNamed(BleConnectionPage.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
