import 'package:altio/backend/api_requests/api/server.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/battery_widget.dart';
import 'package:altio/pages/home/local_sync.dart';
import 'package:altio/pages/settings/presentation/pages/settings_page.dart';
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
  final bool? showRefreshIcon;
  final bool? showProfileIcon;
  final bool? showLocalSync;

  final bool? showAppBar;
  final bool? centerTitle;
  final double? titleSpacing;
  final VoidCallback? onBackBtnPressed;
  final VoidCallback? onRefresh;
  final VoidCallback? onProfileIconPressed;
  final List<Widget>? actions;

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
    this.showAppBar = true,
    this.showRefreshIcon = false,
    this.showProfileIcon = false,
    this.showLocalSync = false,
    this.centerTitle,
    this.titleSpacing,
    this.onBackBtnPressed,
    this.onRefresh,
    this.onProfileIconPressed,
    this.actions,
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
              leadingWidth: 35.0,
              titleSpacing: widget.titleSpacing ?? 10,
              surfaceTintColor: AppColors.white,
              centerTitle: widget.centerTitle ?? true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.appBarTheme.backgroundColor,
              elevation: 0,
              leading: widget.showBackBtn
                  ? InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.onBackBtnPressed != null) {
                          widget.onBackBtnPressed!();
                        }
                      },
                      child: const Icon(Icons.arrow_back_ios_new_rounded),
                    )
                  : null,
              title: widget.title,
              actions: [
                if (widget.showBatteryLevel && widget.batteryLevel != -1)
                  SizedBox(
                    width: 30,
                    child: BatteryWidget(batteryLevel: widget.batteryLevel),
                  ),
                if (widget.showRefreshIcon == true)
                  GestureDetector(
                    onTap: widget.onRefresh,
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.purpleDark,
                    ),
                  ),
                if (widget.showProfileIcon == true)
                  GestureDetector(
                    onTap: widget.onProfileIconPressed,
                    child: const Icon(
                      Icons.account_circle_rounded,
                      size: 33,
                      color: AppColors.purpleDark,
                    ),
                  ),
                ...?widget.actions,
                if (widget.showLocalSync == true)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const LocalSync(),
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
                    child: const Icon(
                      Icons.sync_rounded,
                      size: 28,
                      color: AppColors.purpleDark,
                    ),
                  ),
                w8,
                if (widget.showGearIcon)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SettingsPage(),
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
                    child: Image.asset(
                      width: 23,
                      AppImages.gearIcon,
                    ),
                  ),
                w10,
              ],
            )
          : null,
      body: Container(
        decoration: theme.brightness == Brightness.light
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.2, 1.0],
                  colors: [AppColors.white, AppColors.commonPink],
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.2, 1.0],
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
