// ignore_for_file: unused_local_variable

import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/bloc/bluetooth_bloc.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/home/device.dart';
import 'package:avm/pages/onboarding/find_device/page.dart';
import 'package:avm/pages/plugins/zapier/zapier_page.dart';
import 'package:avm/pages/settings/presentation/widgets/language_dropdown.dart';
import 'package:avm/pages/settings/widgets/calendar.dart';
import 'package:avm/pages/settings/widgets/developer_page.dart';
import 'package:avm/pages/settings/widgets/item_add_on.dart';
import 'package:avm/pages/settings/widgets/profile.dart';
import 'package:avm/src/common_widget/list_tile.dart';
import 'package:avm/utils/other/temp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

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
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
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
                BlocBuilder<BluetoothBloc, BluetoothState>(
                  builder: (context, state) {
                    bool isDeviceDisconnected = state is BluetoothDisconnected;
                    String deviceInfo = 'Device not connected';
                    int batteryLevel = -1;

                    if (state is BluetoothConnected) {
                      deviceInfo = 'Battery Level: ${state.batteryLevel}%';
                      batteryLevel = state.batteryLevel;
                    }

                    return CustomListTile(
                      onTap: () {
                        var deviceId = state is BluetoothConnected
                            ? state.device.id
                            : SharedPreferencesUtil().deviceId;
                        var deviceName = state is BluetoothConnected
                            ? state.device.name
                            : SharedPreferencesUtil().deviceName;
                        var deviceConnected = state is BluetoothConnected;

                        if (deviceConnected) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConnectedDevice(
                                device: state.device,
                                batteryLevel: batteryLevel,
                              ),
                            ),
                          );
                          MixpanelManager().batteryIndicatorClicked();
                        } else if (isDeviceDisconnected &&
                            deviceId.isNotEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConnectedDevice(
                                device: null,
                                batteryLevel: -1,
                              ),
                              // const ConnectDevicePage(),
                            ),
                          );
                          MixpanelManager().connectFriendClicked();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FindDevicesPage(
                                goNext: () {},
                              ),
                              // const ConnectDevicePage(),
                            ),
                          );
                          MixpanelManager().connectFriendClicked();
                        }
                      },
                      title: Row(
                        children: [
                          if (batteryLevel > 0) ...[
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.electric_bolt,
                                size: 13,
                                color: AppColors.white,
                              ),
                            ),
                            w10
                          ],
                          Text(
                            deviceInfo,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 17),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.black,
                            size: 16,
                          )
                        ],
                      ),
                    );
                  },
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
