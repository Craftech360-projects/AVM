import 'package:capsaul/backend/api_requests/api/server.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/bt_device.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/core/widgets/battery_widget.dart';
import 'package:capsaul/pages/settings/presentation/pages/setting_page.dart';
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
  final bool? centerTitle;
  final double? titleSpacing;
  final VoidCallback? onBackBtnPressed;

  const CustomScaffold({
    super.key,
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
    this.showAppBar = true,
    this.centerTitle,
    this.titleSpacing,
    this.onBackBtnPressed,
  });

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showAppBar == true
          ? AppBar(
              titleSpacing: widget.titleSpacing ?? 0,
              surfaceTintColor: AppColors.white,
              centerTitle: widget.centerTitle ?? true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              leading: widget.showBackBtn
                  ? IconButton(
                      alignment: Alignment.topLeft,
                      visualDensity: VisualDensity(horizontal: 4, vertical: 4),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.onBackBtnPressed != null) {
                          widget.onBackBtnPressed!();
                        }
                      },
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SettingPage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var fadeInAnimation =
                                Tween(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: animation, curve: Curves.easeOut),
                            );

                            return FadeTransition(
                              opacity: fadeInAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: AppColors.white,
                      child: Image.asset(
                        width: 26,
                        AppImages.gearIcon,
                      ),
                    ),
                  ),
                w8,
              ],
            )
          : null,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        decoration: theme.brightness == Brightness.light
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3, 1.0],
                  colors: [AppColors.white, AppColors.commonPink],
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3, 1.0],
                  colors: [AppColors.black, AppColors.brightGrey],
                ),
              ),
        child: widget.body,
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset ?? true,
    );
  }
}
