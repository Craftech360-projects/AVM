import 'package:flutter/material.dart';
import 'package:friend_private/src/features/chats/presentation/pages/chats_page.dart';
import 'package:friend_private/src/features/live_transcript/presentation/pages/transcript_memory_page.dart';
import 'package:friend_private/src/features/live_transcript/presentation/pages/ws_testpage.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/finalize_page.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/signin_page.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/wizard_page.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'parent');
const _scaffoldKey = ValueKey('_scaffoldKey');

const _routeAnimationDuration = 1;
const _routeTransitionDuration = 300;

class AppRouter {
  GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/wsPage',
    // initialLocation: '/setting',

    // initialLocation: '/signin',
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
        path: '/ble-connection',
        name: BleConnectionPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const BleConnectionPage(),
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
          child: const FinalizePage(),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        path: '/transcript-memory',
        name: TranscriptMemoryPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const TranscriptMemoryPage(),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
        routes: [
          GoRoute(
            path: '/memory-detail',
            name: MemoryDetailPage.name,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MemoryDetailPage(),
              transitionDuration: const Duration(
                milliseconds: _routeTransitionDuration,
              ),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ),
          )
        ],
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
      GoRoute(
        path: '/chats',
        name: ChatsPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ChatsPage(),
          transitionDuration: const Duration(
            milliseconds: _routeTransitionDuration,
          ),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
        ),
      ),
      GoRoute(
        path: '/wsPage',
        name: WebSocketTestPage.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          child:  WebSocketTestPage(),
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
