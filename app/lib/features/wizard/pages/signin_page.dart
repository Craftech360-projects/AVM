// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/auth.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/src/common_widget/elevated_button.dart';
import 'package:friend_private/utils/legal/privacy_policy.dart';
import 'package:friend_private/utils/legal/terms_and_condition.dart';
import 'package:friend_private/features/wizard/pages/wizard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});
  static const String name = 'SigninPage';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        // Background Image
        Positioned(
          top: MediaQuery.of(context).size.height / 3 -
              30.h / 2, // One-third height minus half logo height
          left: 16.0, // Horizontal padding from the left
          child: Image.asset(
            AppImages.appLogo,
            height: 30.h, // Adjust the logo size as needed
          ),
        ),

        // Foreground Content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 150.h),
              // Image.asset(
              //   AppImages.appLogo,
              //   height: 30.h,
              // ),

              Expanded(
                flex: 6,
                child: Center(
                  child: Text(
                    'Your personal growth journey with AI that '
                    'listens to all your queries.',
                    style: textTheme.displaySmall,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              // Google Sign-in Button
              if (!Platform.isIOS) ...[
                SizedBox(
                  height: 50.h,
                  width: double.maxFinite,
                  child: CustomElevatedButton(
                    backgroundColor: AppColors.white,
                    icon: SvgPicture.asset(
                      AppImages.googleLogo,
                      height: 22.h,
                      width: 22.h,
                    ),
                    onPressed: () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final userCred = await signInWithGoogle();
                        final token = userCred != null
                            ? await userCred.user?.getIdToken()
                            : null;

                        if (token != null) {
                          prefs.setString('firebase_token', token);
                          final user = FirebaseAuth.instance.currentUser!;
                          final prevUid = prefs.getString('uid') ?? '';

                          if (prevUid.isNotEmpty && prevUid != user.uid) {
                            await migrateUserServer(prevUid, user.uid);
                            prefs.setString('last_login_time',
                                DateTime.now().toIso8601String());
                          }
                         
                          prefs.setString('uid', user.uid);
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingPage(),
                            ),
                          );
                        } else {
                          log("Sign-in failed or user token is null");
                        }
                      } catch (e) {
                        log("Google Sign-in failed: $e");
                      }
                    },
                    child: Text(
                      '  Continue using Google',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // Apple Sign-in Button
              if (Platform.isIOS)
                SizedBox(
                  height: 50.h,
                  width: double.maxFinite,
                  child: CustomElevatedButton(
                    backgroundColor: AppColors.white,
                    icon: Icon(
                      Icons.apple, // Using the Apple icon
                      size: 22.h,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final userCred = await signInWithApple();
                        final token = userCred != null
                            ? await userCred.user?.getIdToken()
                            : null;

                        if (token != null) {
                          prefs.setString('firebase_token', token);
                          final user = FirebaseAuth.instance.currentUser!;
                          final prevUid = prefs.getString('uid') ?? '';

                          if (prevUid.isNotEmpty && prevUid != user.uid) {
                            await migrateUserServer(prevUid, user.uid);
                            prefs.setString('last_login_time',
                                DateTime.now().toIso8601String());
                          }

                          prefs.setString('uid', user.uid);
                          prefs.setString('uid', user.uid);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingPage(),
                            ),
                          );
                        } else {
                          log("Apple Sign-in failed or user token is null");
                        }
                      } catch (e) {
                        log("Apple Sign-in failed: $e");
                      }
                    },
                    child: Text(
                      '  Continue using Apple',
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ),
              SizedBox(height: 16.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  children: [
                    const TextSpan(
                        text: 'By signing up for AVM, you agree to '),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showTermsDialog(context);
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showPrivacyPolicy(context);
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ],
    );
  }
}