import 'package:capsoul/backend/mixpanel.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/assets/app_images.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/pages/home/custom_scaffold.dart';
import 'package:capsoul/utils/features/calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  static const String name = 'calenderPage';

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Calendar> calendars = [];
  bool calendarEnabled = false;

  @override
  void initState() {
    super.initState();
    calendarEnabled = SharedPreferencesUtil().calendarEnabled;
    if (calendarEnabled) _getCalendars();
  }

  Future<void> _getCalendars() async {
    final value = await CalendarUtil().getCalendars();
    setState(() => calendars = value);
  }

  void _onSwitchChanged(bool value) async {
    if (value) {
      await _getCalendars();
      SharedPreferencesUtil().calendarEnabled = value;
      MixpanelManager().calendarEnabled();
    } else {
      SharedPreferencesUtil().calendarEnabled = value;
      SharedPreferencesUtil().calendarId = '';
      SharedPreferencesUtil().calendarType = 'auto';
      MixpanelManager().calendarDisabled();
    }
    setState(() {
      calendarEnabled = value;
    });
  }

  List<Widget> _calendarType() {
    return [
      RadioListTile(
        fillColor: WidgetStatePropertyAll(AppColors.purpleDark),
        title: const Text('Automatic'),
        subtitle: const Text('AVM will auto-schedule your events.'),
        value: 'auto',
        groupValue: SharedPreferencesUtil().calendarType,
        onChanged: (String? value) {
          SharedPreferencesUtil().calendarType = value!;
          MixpanelManager().calendarTypeChanged(value);
          setState(() {});
        },
      ),
      RadioListTile(
        fillColor: WidgetStatePropertyAll(AppColors.purpleDark),
        title: const Text('Manual'),
        subtitle: const Text(
            'Events will be drafted, but you must confirm their creation.'),
        value: 'manual',
        groupValue: SharedPreferencesUtil().calendarType,
        onChanged: (String? value) {
          SharedPreferencesUtil().calendarType = value!;
          MixpanelManager().calendarTypeChanged(value);
          setState(() {});
        },
      ),
    ];
  }

  List<Widget> _displayCalendars() {
    final textTheme = Theme.of(context).textTheme;
    return [
      // h15,
      Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.commonPink,
          borderRadius: br8,
        ),
        child: Text(
          textAlign: TextAlign.center,
          'Calendars',
          style: textTheme.titleSmall?.copyWith(fontSize: 16.h),
        ),
      ),
      Text(
        'Select a calendar for AVM to connect to.',
        textAlign: TextAlign.center,
      ),
      h10,
      for (var calendar in calendars)
        RadioListTile(
          fillColor: WidgetStatePropertyAll(AppColors.purpleDark),
          title: Text(calendar.name!),
          subtitle: Text(calendar.accountName!),
          value: calendar.id!,
          groupValue: SharedPreferencesUtil().calendarId,
          onChanged: (String? value) {
            SharedPreferencesUtil().calendarId = value!;
            setState(() {});
            MixpanelManager().calendarSelected();
            avmSnackBar(context, "Calendar ${calendar.name} selected");
          },
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      title: const Center(
        child: Text(
          "Calendar Settings",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
        ),
      ),
      showGearIcon: true,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_calendar),
                    w15,
                    Text(
                      'Enable integration',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
                Switch(
                  activeTrackColor: AppColors.purpleDark,
                  activeColor: AppColors.commonPink,
                  activeThumbImage: AssetImage(AppImages.appLogo),
                  value: calendarEnabled,
                  onChanged: _onSwitchChanged,
                ),
              ],
            ),
          ),
          if (!calendarEnabled)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'AVM can auto-schedule events or ask for your confirmation first.',
                textAlign: TextAlign.center,
              ),
            ),
          if (calendarEnabled) ..._calendarType(),
          if (calendarEnabled) ..._displayCalendars(),
        ],
      ),
    );
  }
}
