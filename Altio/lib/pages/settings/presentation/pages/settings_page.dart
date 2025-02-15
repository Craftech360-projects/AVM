import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/list_tile.dart';
import 'package:altio/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/pages/home/device.dart';
import 'package:altio/pages/onboarding/page.dart';
import 'package:altio/pages/settings/presentation/widgets/language_dropdown.dart';
import 'package:altio/pages/settings/widgets/calendar.dart';
import 'package:altio/pages/settings/widgets/developer_page.dart';
import 'package:altio/pages/settings/widgets/item_add_on.dart';
import 'package:altio/pages/settings/widgets/profile.dart';
import 'package:altio/pages/settings/widgets/zapier_page.dart';
import 'package:altio/utils/other/temp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String name = 'settingsPage';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String version = '';
  String buildVersion = '';
  String selectedModel = "llama-3.3-70b-versatile";
  bool? hasDevice;

  @override
  void initState() {
    super.initState();
    _getVersionInfo();
    _loadSelectedModel();
    _loadDeviceFlag();
  }

  Future<void> _loadDeviceFlag() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool? flag = await DeviceFlagService().fetchDeviceFlag(uid: user.uid);
      setState(() {
        hasDevice = flag;
      });
    }
  }

  // Load the selected model from SharedPreferences
  void _loadSelectedModel() {
    setState(() {
      selectedModel = SharedPreferencesUtil().selectedModel;
    });
  }

  // Update the selected model in SharedPreferences
  void _updateSelectedModel(String newModel) {
    setState(() {
      selectedModel = newModel;
      SharedPreferencesUtil().selectedModel = newModel;
    });
  }

  Future<void> _getVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildVersion = packageInfo.buildNumber;
    });
  }

  Widget _buildModelDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.greyLavender,
        borderRadius: br8,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedModel,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        items: [
          DropdownMenuItem(
            value: "deepseek-r1-distill-llama-70b",
            child: Text(
              "DeepSeek R1 Distill 70B",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          DropdownMenuItem(
            value: "llama-3.3-70b-versatile",
            child: Text(
              "LLaMA 3.3 70B Versatile",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateSelectedModel(value);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: Text(
        "Settings",
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showBackBtn: true,
      showBatteryLevel: true,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              children: [
                BlocBuilder<BluetoothBloc, BluetoothState>(
                  builder: (context, state) {
                    String deviceInfo = 'Device not connected';
                    int batteryLevel = -1;

                    if (state is BluetoothConnected) {
                      deviceInfo = 'Battery Level: ${state.batteryLevel}%';
                      batteryLevel = state.batteryLevel;
                    }

                    return CustomListTile(
                      onTap: () {
                        if (state is BluetoothConnected) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ConnectedDevice(
                                device: state.device,
                                batteryLevel: batteryLevel,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FindDevicesPage(
                                goNext: () {},
                              ),
                            ),
                          );
                        }
                      },
                      title: Row(
                        children: [
                          if (batteryLevel > 0) ...[
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.electric_bolt,
                                size: 13,
                                color: AppColors.white,
                              ),
                            ),
                            w8,
                          ],
                          Text(
                            deviceInfo,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.black),
                h4,
                Text(
                  'AI Model',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                _buildModelDropdown(),
                h16,
                Text(
                  'Recording Settings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const LanguageDropdown(),
                h16,
                Text(
                  'Add Ons',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Divider(color: AppColors.black),
                h4,
                ItemAddOn(
                  title: 'Profile',
                  onTap: () {
                    routeToPage(
                        context, ProfilePage(hasDevice: hasDevice ?? false));
                  },
                  icon: Icons.person,
                ),
                if (hasDevice ?? false)
                  ItemAddOn(
                    title: 'Calendar',
                    onTap: () {
                      routeToPage(context, const CalendarPage());
                    },
                    icon: Icons.calendar_month,
                  ),
                if (hasDevice ?? false)
                  ItemAddOn(
                    title: 'Developer Options',
                    onTap: () {
                      routeToPage(context, const DeveloperPage());
                    },
                    icon: Icons.settings_suggest,
                  ),
                if (hasDevice ?? false)
                  ItemAddOn(
                    title: 'Zapier',
                    onTap: () {
                      routeToPage(context, const ZapierPage());
                    },
                    icon: Icons.settings_suggest,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Version: $version+$buildVersion',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
