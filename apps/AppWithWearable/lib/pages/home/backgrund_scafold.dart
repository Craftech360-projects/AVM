import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/widgets/battery_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:friend_private/pages/settings/page.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomSheet;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? drawerScrimColor;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;
  final String? restorationId;
  final BTDeviceStruct? device; // Optional parameter
  final int batteryLevel; // Optional with default value
// Add batteryLevel parameter
  const CustomScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.restorationId,
    this.device,
    this.batteryLevel = -1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 246, 253, 255),
        leading: BatteryIndicator(batteryLevel: batteryLevel),
        actions: [
          // CircleAvatar(
          //   backgroundColor: CustomColors.greyLavender,
          //   child: CustomIconButton(
          //     size: 20.h,
          //     iconPath: IconImage.gear,
          //     onPressed: () {
          //       print("here");
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) =>
          //               SettingPage(device: device, batteryLevel: batteryLevel),
          //         ),
          //       );
          //     },
          //   ),
          // )
          GestureDetector(
            onTap: () {
              print("Outer CircleAvatar tapped");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingPage(device: device, batteryLevel: batteryLevel),
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: CustomColors.greyLavender,
              child: CustomIconButton(
                size: 20.h,
                iconPath: IconImage.gear,
                onPressed: () {
                  print("Inner button pressed");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingPage(
                          device: device, batteryLevel: batteryLevel),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_image.png',
              fit: BoxFit.cover,
            ),
          ),
          body,
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
  }
}
