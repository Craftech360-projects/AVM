import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/auth.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthComponent extends StatefulWidget {
  final VoidCallback onSignIn;

  const AuthComponent({super.key, required this.onSignIn});

  @override
  State<AuthComponent> createState() => _AuthComponentState();
}

class _AuthComponentState extends State<AuthComponent> {
  bool loading = false;

  changeLoadingState() => setState(() => loading = !loading);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: SizedBox(
              height: 24,
              width: 24,
              child: loading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          !Platform.isIOS
              ? SignInButton(
                  Buttons.google,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: loading
                      ? () {}
                      : () async {
                          changeLoadingState();
                          try {
                            await signInWithGoogle();
                            _signIn();
                          } catch (e) {
                            print("Google Sign-in failed: $e");
                          } finally {
                            changeLoadingState();
                          }
                        },
                )
              : SignInButton(
                  Buttons.google,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: loading
                      ? () {}
                      : () async {
                          changeLoadingState();
                          try {
                            await signInWithGoogle2();
                            _signIn();
                          } catch (e) {
                            print("Google Sign-in failed: $e");
                          } finally {
                            changeLoadingState();
                          }
                        },
                ),
          const SizedBox(height: 16),
          SignInWithAppleButton(
            style: SignInWithAppleButtonStyle.whiteOutlined,
            onPressed: loading
                ? () {}
                : () async {
                    try {
                      changeLoadingState();
                      var userCred = await signInWithApple();

                      _signIn();
                    } catch (e) {
                      print("Error during sign-in: $e");
                    } finally {
                      changeLoadingState(); // This will ensure loading state is reset in all cases.
                    }
                  },
            height: 52,
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              // style: const TextStyle(color: Colors.white, fontSize: 12),
              style: textTheme.bodySmall?.copyWith(color: AppColors.grey),
              children: [
                const TextSpan(text: 'By Signing in, you agree to our\n'),
                TextSpan(
                  text: 'Terms of service',
                  style: const TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap =
                        () => _launchUrl('https://www.craftech360.com/terms'),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl('https://www.craftech360.com/privacy-policy');
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() async {
    String? token;
    try {
      token = await getIdToken();
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to retrieve firebase token, please try again.'),
      ));
      // CrashReporting.reportHandledCrash(e, stackTrace,
      //     level: NonFatalExceptionLevel.error);
      return;
    }
    print('Token: $token');
    if (token != null) {
      User user;
      try {
        user = FirebaseAuth.instance.currentUser!;
      } catch (e, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Unexpected error signing in, Firebase error, please try again.'),
        ));
        // CrashReporting.reportHandledCrash(
        //   e,
        //   stackTrace,
        //   level: NonFatalExceptionLevel.error,
        // );
        return;
      }

      String prevUid = SharedPreferencesUtil().uid;
      String newUid = user.uid;
      if (prevUid.isNotEmpty && prevUid != newUid) {
        MixpanelManager().migrateUser(newUid);
        try {
          await migrateUserServer(prevUid, newUid);
        } catch (e, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Unexpected error retrieving your memories backup.'),
          ));
          // CrashReporting.reportHandledCrash(
          //   e,
          //   stackTrace,
          //   level: NonFatalExceptionLevel.error,
          //   userAttributes: {
          //     'prevUid': prevUid,
          //     'newUid': newUid,
          //   },
          // );
        }
        SharedPreferencesUtil().uid = newUid;
      } else {
        // await retrieveBackup(newUid);
        SharedPreferencesUtil().uid = newUid;
        MixpanelManager().identify();
      }
      widget.onSignIn();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unexpected error signing in, please try again.'),
      ));
    }
  }

  void _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }
}
