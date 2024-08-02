// import 'package:flutter/material.dart';

// class CustomScaffold extends StatelessWidget {
//   final Widget body;
//   final AppBar? appBar;
//   final Widget? bottomNavigationBar;
//   final Widget? floatingActionButton;
//   final FloatingActionButtonLocation? floatingActionButtonLocation;
//   final FloatingActionButtonAnimator? floatingActionButtonAnimator;
//   final List<Widget>? persistentFooterButtons;
//   final Widget? drawer;
//   final Widget? endDrawer;
//   final Widget? bottomSheet;
//   final Color? backgroundColor;
//   final bool? resizeToAvoidBottomInset;
//   final bool primary;
//   final DrawerDragStartBehavior drawerDragStartBehavior;
//   final double? extendBody;
//   final double? extendBodyBehindAppBar;
//   final bool? drawerScrimColor;
//   final bool? drawerEdgeDragWidth;
//   final bool? drawerEnableOpenDragGesture;
//   final bool? endDrawerEnableOpenDragGesture;
//   final String? restorationId;

//   const CustomScaffold({
//     Key? key,
//     required this.body,
//     this.appBar,
//     this.bottomNavigationBar,
//     this.floatingActionButton,
//     this.floatingActionButtonLocation,
//     this.floatingActionButtonAnimator,
//     this.persistentFooterButtons,
//     this.drawer,
//     this.endDrawer,
//     this.bottomSheet,
//     this.backgroundColor,
//     this.resizeToAvoidBottomInset,
//     this.primary = true,
//     this.drawerDragStartBehavior = DrawerDragStartBehavior.start,
//     this.extendBody,
//     this.extendBodyBehindAppBar,
//     this.drawerScrimColor,
//     this.drawerEdgeDragWidth,
//     this.drawerEnableOpenDragGesture,
//     this.endDrawerEnableOpenDragGesture,
//     this.restorationId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/splash.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           body,
//         ],
//       ),
//       bottomNavigationBar: bottomNavigationBar,
//       floatingActionButton: floatingActionButton,
//       floatingActionButtonLocation: floatingActionButtonLocation,
//       floatingActionButtonAnimator: floatingActionButtonAnimator,
//       persistentFooterButtons: persistentFooterButtons,
//       drawer: drawer,
//       endDrawer: endDrawer,
//       bottomSheet: bottomSheet,
//       backgroundColor: backgroundColor,
//       resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//       primary: primary,
//       drawerDragStartBehavior: drawerDragStartBehavior,
//       extendBody: extendBody,
//       extendBodyBehindAppBar: extendBodyBehindAppBar,
//       drawerScrimColor: drawerScrimColor,
//       drawerEdgeDragWidth: drawerEdgeDragWidth,
//       drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
//       endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
//       restorationId: restorationId,
//     );
//   }
// }
