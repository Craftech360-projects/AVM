import 'package:altio/backend/preferences.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/elevated_button.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/pages/home/page.dart';
import 'package:flutter/material.dart';

class FinalizePage extends StatelessWidget {
  final VoidCallback goNext;
  const FinalizePage({super.key, required this.goNext});
  static const String name = 'finalizePage';
  static const String routeName = '/finalizePage';
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.015,
              left: 16,
              right: 16,
              top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.appLogo,
                height: 30,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'You are all set 🎉',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black),
                    borderRadius: br12),
                height: 55,
                width: double.maxFinite,
                child: CustomElevatedButton(
                  backgroundColor: AppColors.white,
                  onPressed: () async {
                    if (SharedPreferencesUtil().onboardingCompleted) {
                      await Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomePageWrapper(tabIndex: 2),
                        ),
                      );
                    }
                  },
                  child: Text('Get Started',
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
