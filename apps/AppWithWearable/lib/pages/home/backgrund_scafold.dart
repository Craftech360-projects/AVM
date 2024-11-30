import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/api_requests/api/server.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/pages/plugins/page.dart';
import 'package:friend_private/pages/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/live_transcript/presentation/widgets/battery_indicator.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/src/core/constant/constant.dart';

class CustomScaffold extends StatefulWidget {
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
  final BTDeviceStruct? device;
  final int batteryLevel;
  final int tabIndex;

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
    this.tabIndex = 1,
  }) : super(key: key);

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  List<Plugin> plugins = [];

  @override
  void initState() {
    super.initState();
    _initiatePlugins();
  }

  Future<void> _initiatePlugins() async {
    plugins = SharedPreferencesUtil().pluginsList;
    plugins = await retrievePlugins();
    _edgeCasePluginNotAvailable();
    setState(() {}); // Rebuild after loading plugins
  }

  void _edgeCasePluginNotAvailable() {
    var selectedChatPlugin = SharedPreferencesUtil().selectedChatPluginId;
    var plugin = plugins.firstWhereOrNull((p) => selectedChatPlugin == p.id);
    if (selectedChatPlugin != 'no_selected' &&
        (plugin == null || !plugin.worksWithChat())) {
      SharedPreferencesUtil().selectedChatPluginId = 'no_selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedValue = SharedPreferencesUtil().selectedChatPluginId;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE6F5FA),
        leading: BatteryIndicator(batteryLevel: widget.batteryLevel),
        actions: [
          // if (widget.tabIndex == 1)
          //   Padding(
          //     padding: const EdgeInsets.only(left: 0),
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 16),
          //       child: DropdownButton<String>(
          //         menuMaxHeight: 350,
          //         value: selectedValue,
          //         onChanged: (s) async {
          //           if (s == null) return;
          //           if ((s == 'no_selected' &&
          //                   SharedPreferencesUtil().pluginsEnabled.isEmpty) ||
          //               s == 'enable') {
          //             await routeToPage(
          //                 context, const PluginsPage(filterChatOnly: true));
          //             return;
          //           }

          //           SharedPreferencesUtil().selectedChatPluginId = s;
          //           var plugin = plugins.firstWhereOrNull((p) => p.id == s);
          //           setState(() {}); // Rebuild to reflect changes
          //         },
          //         icon: Container(),
          //         alignment: Alignment.center,
          //         dropdownColor: CustomColors.greyLight,
          //         style: const TextStyle(color: Colors.white, fontSize: 16),
          //         underline: Container(
          //             height: 0, color: Colors.transparent), // Remove underline
          //         isExpanded: false,
          //         itemHeight: 48,
          //         items: _getPluginsDropdownItems(context),
          //       ),
          //     ),
          //   ),
          GestureDetector(
            onTap: () {
              print("Outer CircleAvatar tapped");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(
                      device: widget.device, batteryLevel: widget.batteryLevel),
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
                          device: widget.device,
                          batteryLevel: widget.batteryLevel),
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
          widget.body,
        ],
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
      persistentFooterButtons: widget.persistentFooterButtons,
      drawer: widget.drawer,
      endDrawer: widget.endDrawer,
      bottomSheet: widget.bottomSheet,
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      primary: widget.primary,
      drawerDragStartBehavior: widget.drawerDragStartBehavior,
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      drawerScrimColor: widget.drawerScrimColor,
      drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      restorationId: widget.restorationId,
    );
  }

  List<DropdownMenuItem<String>> _getPluginsDropdownItems(
      BuildContext context) {
    // Ensure each value is unique and includes "no_selected" if required
    final dropdownItems = [
      DropdownMenuItem<String>(
        value: 'no_selected',
        child: Text('No Selected Plugin'),
      ),
      ...plugins.map<DropdownMenuItem<String>>((Plugin plugin) {
        return DropdownMenuItem<String>(
          value: plugin.id,
          child: Text(plugin.name),
        );
      })
    ];
    return dropdownItems;
  }
}
