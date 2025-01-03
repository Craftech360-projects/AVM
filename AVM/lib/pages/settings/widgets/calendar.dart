import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/utils/features/calendar.dart';
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

  _getCalendars() {
    CalendarUtil().getCalendars().then((value) {
      setState(() => calendars = value);
    });
  }

  @override
  void initState() {
    super.initState();
    calendarEnabled = SharedPreferencesUtil().calendarEnabled;
    if (calendarEnabled) _getCalendars();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showBackBtn: true,
      title: const Text(
        "Calendar Settings",
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
      ),
      showGearIcon: true,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                  value: calendarEnabled,
                  onChanged: _onSwitchChanged,
                ),
              ],
            ),
          ),
          h5,
          const Text(
            'AVM can automatically schedule events from your conversations, or ask for your confirmation first.',
            textAlign: TextAlign.start,
            style: TextStyle(
                color: AppColors.greyMedium, fontWeight: FontWeight.w500),
          ),
          h20,
          if (calendarEnabled) ..._calendarType(),
          h20,
          if (calendarEnabled) ..._displayCalendars(),
        ],
      ),
    );
  }

  _calendarType() {
    return [
      RadioListTile(
        title: const Text('Automatic'),
        subtitle: const Text('AI Will automatically scheduled your events.'),
        value: 'auto',
        groupValue: SharedPreferencesUtil().calendarType,
        onChanged: (v) {
          SharedPreferencesUtil().calendarType = v!;
          MixpanelManager().calendarTypeChanged(v);
          setState(() {});
        },
      ),
      RadioListTile(
        title: const Text('Manual'),
        subtitle: const Text(
            'Your events will be drafted, but you will have to confirm their creation.'),
        value: 'manual',
        groupValue: SharedPreferencesUtil().calendarType,
        onChanged: (v) {
          SharedPreferencesUtil().calendarType = v!;
          MixpanelManager().calendarTypeChanged(v);
          setState(() {});
        },
      ),
    ];
  }

  _displayCalendars() {
    final textTheme = Theme.of(context).textTheme;
    return [
      const SizedBox(height: 16),
      Container(
        margin: EdgeInsets.all(22.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.greyLavender,
          borderRadius: BorderRadius.circular(16.h),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Text(
              'Calendars',
              style: textTheme.titleSmall?.copyWith(fontSize: 16.h),
            ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Select to which calendar you want your AVM to connect to.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.greyMedium,
          ),
        ),
      ),
      const SizedBox(height: 16),
      for (var calendar in calendars)
        RadioListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(calendar.name!),
          subtitle: Text(calendar.accountName!),
          value: calendar.id!,
          groupValue: SharedPreferencesUtil().calendarId,
          onChanged: (String? value) {
            SharedPreferencesUtil().calendarId = value!;
            setState(() {});
            MixpanelManager().calendarSelected();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Calendar ${calendar.name} selected.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        )
    ];
  }

  _onSwitchChanged(s) async {
    //what if user didn't enable permissions?
    if (s) {
      _getCalendars();
      SharedPreferencesUtil().calendarEnabled = s;
      MixpanelManager().calendarEnabled();
    } else {
      SharedPreferencesUtil().calendarEnabled = s;
      SharedPreferencesUtil().calendarId = '';
      SharedPreferencesUtil().calendarType = 'auto';
      MixpanelManager().calendarDisabled();
    }
    setState(() {
      calendarEnabled = s;
    });
  }
}
