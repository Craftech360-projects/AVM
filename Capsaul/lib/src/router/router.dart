import 'package:capsaul/features/wizard/pages/finalize_page.dart';
import 'package:capsaul/features/wizard/pages/signin_page.dart';
import 'package:capsaul/features/wizard/pages/wizard_page.dart';
import 'package:capsaul/pages/settings/presentation/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'parent');
const scaffoldKey = ValueKey('_scaffoldKey');

const _routeAnimationDuration = 1;
const _routeTransitionDuration = 300;

class AppRouter {
  GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/signin',
        name: SigninPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SigninPage(),
          transitionDuration: const Duration(
            seconds: _routeAnimationDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: OnboardingPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const OnboardingPage(),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        path: '/finalize-onboarding',
        name: FinalizePage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: FinalizePage(
            goNext: () {},
          ),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        path: '/setting',
        name: SettingPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingPage(),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
    ],
    debugLogDiagnostics: true,
  );
}
