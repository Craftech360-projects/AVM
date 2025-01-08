import 'package:capsoul/backend/api_requests/api/server.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/backend/schema/plugin.dart';
import 'package:capsoul/core/assets/app_images.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/core/widgets/battery_widget.dart';
import 'package:capsoul/pages/settings/presentation/pages/setting_page.dart';
import 'package:capsoul/src/common_widget/icon_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? title;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final BTDeviceStruct? device;
  final int batteryLevel;
  final int tabIndex;
  final bool showBackBtn;
  final bool showBatteryLevel;
  final bool showGearIcon;
  final bool showDateTime;
  final bool? showAppBar;

  const CustomScaffold(
      {super.key,
      required this.body,
      this.appBar,
      this.title,
      this.bottomNavigationBar,
      this.floatingActionButton,
      this.resizeToAvoidBottomInset,
      this.device,
      this.batteryLevel = -1,
      this.tabIndex = 1,
      this.showBackBtn = false,
      this.showBatteryLevel = false,
      this.showGearIcon = false,
      this.showDateTime = false,
      this.showAppBar = true});

  @override
  CustomScaffoldState createState() => CustomScaffoldState();
}

class CustomScaffoldState extends State<CustomScaffold> {
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
    setState(() {});
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
    return Scaffold(
      appBar: widget.showAppBar == true
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: widget.showBackBtn
                  ? IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded))
                  : null,
              title: widget.title,
              actions: [
                if (widget.showBatteryLevel && widget.batteryLevel != -1)
                  SizedBox(
                    width: 30,
                    child: BatteryWidget(batteryLevel: widget.batteryLevel),
                  ),
                if (widget.showGearIcon)
                  CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: GestureDetector(
                      child: CustomIconButton(
                        size: 25,
                        iconPath: AppImages.gearIcon,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                w10,
              ],
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3, 1.0],
            colors: [AppColors.white, AppColors.commonPink],
          ),
        ),
        child: widget.body,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
    );
  }
}
