import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/home/page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/pages/transcript_memory_page.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:go_router/go_router.dart';

class FinalizePage extends StatelessWidget {
  const FinalizePage({super.key});
  static const String name = 'finalizePage';
  //static const String name = 'finalizePage';
  static const String routeName = '/finalizePage';
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      IconImage.avmLogo,
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
                child: CustomElevatedButton(
                  backgroundColor: CustomColors.blackPrimary,
                  onPressed: () {
                    if (SharedPreferencesUtil().onboardingCompleted) {
                      // previous users
                      routeToPage(context, const HomePageWrapper(),
                          replace: true);
                    }
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         const HomePageWrapper(), // Replace with your next page widget
                    //   ),
                    // );
                  },
                  child: Text(
                    'Get Started',
                    style: textTheme.labelLarge?.copyWith(
                      color: CustomColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
