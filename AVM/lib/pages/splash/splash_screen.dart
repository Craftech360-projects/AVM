import 'dart:async';

import 'package:avm/backend/preferences.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/features/wizard/pages/signin_page.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/home/page.dart';
import 'package:flutter/material.dart';

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