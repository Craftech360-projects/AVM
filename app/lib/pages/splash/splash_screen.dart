import 'dart:async';

import 'package:flutter/material.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/features/wizard/pages/signin_page.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/home/page.dart';

class SplashScreen extends StatefulWidget {
  final bool isAuth;

  const SplashScreen({super.key, required this.isAuth});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(milliseconds: 4000), () {
      SharedPreferencesUtil().onboardingCompleted && widget.isAuth
          ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomePageWrapper()),
            )
          : Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const SigninPage()),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1500),
          child: Image.asset(
            AppImages.appLogo,
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }
}
