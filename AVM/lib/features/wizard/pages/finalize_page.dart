import 'package:avm/backend/preferences.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/home/page.dart';
import 'package:avm/src/common_widget/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.appLogo,
                height: 30.h,
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                          height: 1.5,
                          color: AppColors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Montserrat"),
                      children: [
                        TextSpan(
                          text: "You're all set up and\n",
                          style: TextStyle(fontSize: 20),
                        ),
                        TextSpan(
                          text: "Ready to go!",
                          style: TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black),
                    borderRadius: br12),
                height: 55.h,
                width: double.maxFinite,
                child: CustomElevatedButton(
                  backgroundColor: AppColors.white,
                  onPressed: () async {
                    if (SharedPreferencesUtil().onboardingCompleted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePageWrapper(),
                        ),
                      );
                    }
                  },
                  child: const Text('Get Started',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                          fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
