import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/utils/features/calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

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
    print("calender geting>>>>>>>>>>>>>>>>>");
  }

  @override
  void initState() {
    super.initState();
    calendarEnabled = SharedPreferencesUtil().calendarEnabled;
    if (calendarEnabled) _getCalendars();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
        // appBar: AppBar(
        //   title: const Text('Calendar'),
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   elevation: 0,
        // ),
        appBar: AppBar(
          centerTitle: true,
          // backgroundColor: const Color(0xFFE6F5FA),
          backgroundColor: const Color(0xFFE6F5FA),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pushNamed(
                  SettingPage.name); // Go back to the previous screen
            },
          ),
          title: Text(
            'Calender',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 20.h,
            ),
          ),
        ),
        // backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: const Color(0xFFE6F5FA),
        body: Container(
            color: const Color(
                0xFFE6F5FA), // Set your desired background color here
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.edit_calendar),
                              SizedBox(width: 16),
                              Text(
                                'Enable integration',
                                style: TextStyle(
                                  color: CustomColors.blackPrimary,
                                  fontSize: 16,
                                ),
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
                  ),
                  const Text(
                    'AVM can automatically schedule events from your conversations, or ask for your confirmation first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (calendarEnabled) ..._calendarType(),
                  const SizedBox(height: 24),
                  if (calendarEnabled) ..._displayCalendars(),
                ],
              ),
            ))
        //  ListView(
        //   children: [
        //     Container(
        //       margin: const EdgeInsets.all(8),
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       child: SizedBox(
        //         width: double.infinity,
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             const Row(
        //               children: [
        //                 Icon(Icons.edit_calendar),
        //                 SizedBox(width: 16),
        //                 Text(
        //                   'Enable integration',
        //                   style: TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 16,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //             Switch(
        //               value: calendarEnabled,
        //               onChanged: _onSwitchChanged,
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     const Text(
        //       'AVM can automatically schedule events from your conversations, or ask for your confirmation first.',
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //         color: Colors.grey,
        //       ),
        //     ),
        //     const SizedBox(height: 24),
        //     if (calendarEnabled) ..._calendarType(),
        //     const SizedBox(height: 24),
        //     if (calendarEnabled) ..._displayCalendars(),
        //   ],
        // ),
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
      // Container(
      //   margin: const EdgeInsets.all(16),
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //   decoration: const BoxDecoration(
      //     borderRadius: BorderRadius.all(Radius.circular(8)),
      //     border: GradientBoxBorder(
      //       gradient: LinearGradient(colors: [
      //         CustomColors.purpleBright,
      //         CustomColors.purpleBright,
      //         // const Color.fromARGB(227, 255, 255, 255)
      //       ]),
      //       width: 1,
      //     ),
      //     shape: BoxShape.rectangle,
      //   ),
      //   child: const Center(
      //       child: Padding(
      //     padding: EdgeInsets.symmetric(vertical: 4),
      //     child: Text('Calendars'),
      //   )),
      // ),
      Container(
        margin: EdgeInsets.all(22.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: CustomColors.greyLavender,
          borderRadius: BorderRadius.circular(16.h),
          // border: Border.all(
          //   color: CustomColors.purpleBright,
          //   width: 1.w,
          // ),
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
            color: Colors.grey,
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
    // TODO: what if user didn't enable permissions?
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
