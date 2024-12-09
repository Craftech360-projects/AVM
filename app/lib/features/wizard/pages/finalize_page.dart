import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/home/page.dart';

class FinalizePage extends StatelessWidget {
  const FinalizePage({super.key});
  static const String name = 'finalizePage';
  //static const String name = 'finalizePage';
  static const String routeName = '/finalizePage';
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png', // Replace with your image asset path
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Foreground content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(14.w), // Retains the same padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.appLogo,
                          height: 30.h,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'You are all set 🎉',
                          style: textTheme.displaySmall,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                      ),
                      onPressed: () {
                        if (SharedPreferencesUtil().onboardingCompleted) {
                          // previous users
                          //   routeToPage(context, const HomePageWrapper(),
                          //       replace: true);
                          // }
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePageWrapper(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Get Started',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
