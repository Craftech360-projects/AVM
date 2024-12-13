import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/pages/home/device.dart';
import 'package:friend_private/pages/onboarding/find_device/page.dart';
import 'package:friend_private/pages/plugins/zapier/zapier_page.dart';
import 'package:friend_private/pages/settings/presentation/widgets/language_dropdown.dart';
import 'package:friend_private/pages/settings/widgets/calendar.dart';
import 'package:friend_private/pages/settings/widgets/developer_page.dart';
import 'package:friend_private/pages/settings/widgets/item_add_on.dart';
import 'package:friend_private/pages/settings/widgets/profile.dart';
import 'package:friend_private/src/common_widget/list_tile.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  final BTDeviceStruct? device;
  final int batteryLevel;

  const SettingPage({
    this.device,
    this.batteryLevel = -1,
    super.key,
  });

  static const String name = 'settingPage';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String version = '';
  String buildVersion = '';

  @override
  void initState() {
    super.initState();
    _getVersionInfo();
  }

  Future<void> _getVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildVersion = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      title: const Center(
        child: Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      showBackBtn: true,
      showBatteryLevel: true,
      body: Column(
        children: [
          // ListView wrapped in Expanded to fill remaining space
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
              children: [
                CustomListTile(
                  onTap: () {
                    if (widget.device != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConnectedDevice(
                            device: widget.device,
                            batteryLevel: widget.batteryLevel,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FindDevicesPage(
                            goNext: () {},
                          ),
                        ),
                      );
                    }
                  },
                  title: Text(
                    widget.batteryLevel > 0
                        ? 'Battery Level: ${widget.batteryLevel}%'
                        : 'Device not connected',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: const CircleAvatar(
                    backgroundColor: AppColors.greyLavender,
                    child: Icon(Icons.bluetooth_searching),
                  ),
                ),
                h15,
                Text(
                  'Recording Settings',
                  style: textTheme.titleMedium
                      ?.copyWith(fontSize: 20.h, fontWeight: FontWeight.w600),
                ),
                h5,
                const LanguageDropdown(),
                h30,
                Text(
                  'Add Ons',
                  style: textTheme.titleMedium
                      ?.copyWith(fontSize: 20.h, fontWeight: FontWeight.w600),
                ),
                h5,
                ItemAddOn(
                  title: 'Profile',
                  onTap: () {
                    routeToPage(context, const ProfilePage());
                  },
                  icon: Icons.person,
                ),
                ItemAddOn(
                  title: 'Calendar',
                  onTap: () {
                    routeToPage(context, const CalendarPage());
                  },
                  icon: Icons.calendar_month,
                ),
                ItemAddOn(
                  title: 'Developer Options',
                  onTap: () {
                    routeToPage(context, const DeveloperPage());
                  },
                  icon: Icons.settings_suggest,
                ),
                ItemAddOn(
                  title: 'Zapier',
                  onTap: () {
                    routeToPage(context, const ZapierPage());
                  },
                  icon: Icons.settings_suggest,
                ),
                h20,
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Version: $version+$buildVersion',
              style: const TextStyle(
                  color: Color.fromARGB(255, 150, 150, 150),
                  fontSize: 14,
                  height: 3,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
