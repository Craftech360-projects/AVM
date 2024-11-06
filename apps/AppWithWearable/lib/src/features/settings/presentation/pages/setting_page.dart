import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/add_ons.dart';
import 'package:friend_private/src/features/settings/presentation/widgets/language_dropdown.dart';
import 'package:friend_private/src/features/wizard/presentation/pages/ble_connection_page.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({
    super.key,
  });
  static const String name = 'settingPage';
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFE6F5FA),
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        children: [
          CustomListTile(
            onTap: () {
              context.pushNamed(BleConnectionPage.name);
            },
            title: Text(
              'Device Battery - 66%',
              style: textTheme.bodyLarge,
            ),
            trailing: const CircleAvatar(
              backgroundColor: CustomColors.greyLavender,
              child: Icon(Icons.bluetooth_searching),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Recording Setting',
            style: textTheme.titleMedium?.copyWith(fontSize: 20.h),
          ),
          SizedBox(height: 16.h),
          const LanguageDropdown(),
          SizedBox(height: 16.h),
          Text(
            'Add Ons',
            style: textTheme.titleMedium?.copyWith(fontSize: 20.h),
          ),
          SizedBox(height: 16.h),
          AddOns(
            title: 'Profile',
            onPressed: () {},
          ),
          AddOns(
            title: 'Calender Integration',
            onPressed: () {},
          ),
          AddOns(
            title: 'Developer Option',
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
