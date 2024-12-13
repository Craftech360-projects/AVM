// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/auth.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/wizard/pages/wizard_page.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/src/common_widget/elevated_button.dart';
import 'package:friend_private/utils/legal/privacy_policy.dart';
import 'package:friend_private/utils/legal/terms_and_condition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});
  static const String name = 'SigninPage';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
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
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Your personal growth journey\nwith AI that listens to\nall your queries',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w500, height: 1.2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              h15,
              Column(
                children: [
                  if (!Platform.isIOS) ...[
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          borderRadius: br30),
                      height: 50.h,
                      width: double.maxFinite,
                      child: CustomElevatedButton(
                        backgroundColor: AppColors.white,
                        icon: Image.asset(
                          AppImages.googleLogo,
                          height: 26.h,
                          width: 26.h,
                        ),
                        onPressed: () async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final userCred = await signInWithGoogle();
                            // ignore: unnecessary_null_comparison
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
                        child: const Text(' Continue using Google',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                                fontSize: 18)),
                      ),
                    ),
                  ],

                  // Apple Sign-in Button
                  if (Platform.isIOS)
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.black),
                          borderRadius: br30),
                      height: 55.h,
                      width: double.maxFinite,
                      child: CustomElevatedButton(
                        backgroundColor: AppColors.white,
                        icon: Image.asset(
                          AppImages.appleLogo,
                          height: 26.h,
                          width: 26.h,
                        ),
                        onPressed: () async {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final userCred = await signInWithApple();
                            // ignore: unnecessary_null_comparison
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
                        child: const Text(' Continue using Apple',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                                fontSize: 18)),
                      ),
                    ),
                  h10,
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(
                            text: 'By signing up for AVM, you agree to the \n'),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w500,
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
                  h10,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
