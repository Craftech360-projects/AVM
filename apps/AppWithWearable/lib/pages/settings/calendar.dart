// import 'package:device_calendar/device_calendar.dart';
// import 'package:flutter/material.dart';
// import 'package:AVMe/backend/preferences.dart';
// import 'package:AVMe/utils/features/calendar.dart';
// import 'package:gradient_borders/box_borders/gradient_box_border.dart';

// class CalendarPage extends StatefulWidget {
//   const CalendarPage({super.key});

//   @override
//   State<CalendarPage> createState() => _CalendarPageState();
// }

// class _CalendarPageState extends State<CalendarPage> {
//   List<Calendar> calendars = [];
//   bool calendarEnabled = false;

//   _getCalendars() {
//     CalendarUtil().getCalendars().then((value) {
//       setState(() => calendars = value);
//     });
//   }

//   @override
//   void initState() {
//     calendarEnabled = SharedPreferencesUtil().calendarEnabled;
//     if (calendarEnabled) _getCalendars();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Calendar'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         elevation: 0,
//       ),
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       body: ListView(
//         children: [
//           Container(
//             margin: const EdgeInsets.all(8),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.edit_calendar),
//                     SizedBox(width: 16),
//                     Text(
//                       'Enable integration',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Switch(
//                   value: calendarEnabled,
//                   onChanged: _onSwitchChanged,
//                 ),
//               ],
//             ),
//           ),
//           const Text(
//             'Friend can automatically schedule events from your conversations, or ask for your confirmation first.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 24),
//           if (calendarEnabled) ..._calendarType(),
//           const SizedBox(height: 24),
//           if (calendarEnabled) ..._displayCalendars(),
//         ],
//       ),
//     );
//   }

//   _calendarType() {
//     return [
//       RadioListTile(
//         title: const Text('Automatic'),
//         subtitle: const Text('AI Will automatically scheduled your events.'),
//         value: 'auto',
//         groupValue: SharedPreferencesUtil().calendarType,
//         onChanged: (v) {
//           SharedPreferencesUtil().calendarType = v!;
//           setState(() {});
//         },
//       ),
//       RadioListTile(
//         title: const Text('Manual'),
//         subtitle: const Text(
//             'Your events will be drafted, but you will have to confirm their creation.'),
//         value: 'manual',
//         groupValue: SharedPreferencesUtil().calendarType,
//         onChanged: (v) {
//           SharedPreferencesUtil().calendarType = v!;
//           setState(() {});
//         },
//       ),
//     ];
//   }

//   _displayCalendars() {
//     print("All calendars:");
//     for (var calendar in calendars) {
//       print(
//           "Calendar Name: ${calendar.name}, ID: ${calendar.id}, Account: ${calendar.accountName}");
//     }
//     return [
//       const SizedBox(height: 16),
//       Container(
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(8)),
//           border: GradientBoxBorder(
//             gradient: LinearGradient(colors: [
//               Color.fromARGB(127, 208, 208, 208),
//               Color.fromARGB(127, 188, 99, 121),
//               Color.fromARGB(127, 86, 101, 182),
//               Color.fromARGB(127, 126, 190, 236)
//             ]),
//             width: 2,
//           ),
//           shape: BoxShape.rectangle,
//         ),
//         child: const Center(
//             child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 4),
//           child: Text('Calendars'),
//         )),
//       ),
//       const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8.0),
//         child: Text(
//           'Select to which calendar you want your Friend to connect to.',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.grey,
//           ),
//         ),
//       ),
//       const SizedBox(height: 16),
//       for (var calendar in calendars)
//         RadioListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 24),
//           title: Text(calendar.name!),
//           subtitle: Text(calendar.accountName!),
//           value: calendar.id!,
//           groupValue: SharedPreferencesUtil().calendarId,
//           onChanged: (String? value) {
//             SharedPreferencesUtil().calendarId = value!;
//             setState(() {});
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Calendar ${calendar.name} selected.'),
//                 duration: const Duration(seconds: 1),
//               ),
//             );
//           },
//         )
//     ];
//   }

//   _onSwitchChanged(s) async {
//     // TODO: what if user didn't enable permissions?
//     if (s) {
//       _getCalendars();
//       SharedPreferencesUtil().calendarEnabled = s;
//     } else {
//       SharedPreferencesUtil().calendarEnabled = s;
//       SharedPreferencesUtil().calendarId = '';
//     }
//     setState(() {
//       calendarEnabled = s;
//     });
//   }
// }

//MY CODE
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:AVMe/backend/preferences.dart';
import 'package:AVMe/utils/features/calendar.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  List<Calendar> calendars = [];
  bool calendarEnabled = false;

  Future<bool> _requestPermissions() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      final permissionsResult =
          await _deviceCalendarPlugin.requestPermissions();
      return permissionsResult.isSuccess && permissionsResult.data!;
    }
    return permissionsGranted.isSuccess && permissionsGranted.data!;
  }

  Future<void> _getCalendars() async {
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calendar permissions not granted')),
      );
      return;
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess) {
      setState(() => calendars = calendarsResult.data!);
    }
  }

  @override
  void initState() {
    calendarEnabled = SharedPreferencesUtil().calendarEnabled;
    if (calendarEnabled) _getCalendars();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Calendar', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListView(
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(236, 37, 30, 57),
                        Color.fromARGB(255, 47, 39, 63),
                        Color.fromARGB(236, 37, 30, 57),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(
                      color: const Color.fromARGB(255, 52, 52, 52),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_calendar, color: Colors.white),
                          SizedBox(width: 16),
                          Text(
                            'Enable integration',
                            style: TextStyle(
                              color: Colors.white,
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
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Friend can automatically schedule events from your conversations, or ask for your confirmation first.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (calendarEnabled) ..._calendarType(),
                if (calendarEnabled) ..._displayCalendars(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _calendarType() {
    return [
      RadioListTile(
        title: const Text('Automatic'),
        subtitle: const Text('AI Will automatically schedule your events.'),
        value: 'auto',
        groupValue: SharedPreferencesUtil().calendarType,
        onChanged: (v) {
          SharedPreferencesUtil().calendarType = v!;
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
          setState(() {});
        },
      ),
    ];
  }

  List<Widget> _displayCalendars() {
    return [
      const SizedBox(height: 16),
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(236, 37, 30, 57),
              Color.fromARGB(255, 47, 39, 63),
              Color.fromARGB(236, 37, 30, 57),
            ],
          ),
          border: Border.fromBorderSide(
            BorderSide(color: Color.fromARGB(255, 52, 52, 52), width: 1),
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('Calendars', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Select to which calendar you want your Friend to connect to.',
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
          title: Text(calendar.name!, style: TextStyle(color: Colors.white)),
          subtitle:
              Text(calendar.accountName!, style: TextStyle(color: Colors.grey)),
          value: calendar.id!,
          groupValue: SharedPreferencesUtil().calendarId,
          onChanged: (String? value) {
            SharedPreferencesUtil().calendarId = value!;
            setState(() {});
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

  void _onSwitchChanged(bool s) async {
    if (s) {
      await _getCalendars();
    } else {
      SharedPreferencesUtil().calendarId = '';
    }
    SharedPreferencesUtil().calendarEnabled = s;
    setState(() {
      calendarEnabled = s;
    });
  }
}
