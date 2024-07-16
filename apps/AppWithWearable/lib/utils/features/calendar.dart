import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:AVMe/backend/preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as timezone;

class CalendarUtil {
  static final CalendarUtil _instance = CalendarUtil._internal();
  static DeviceCalendarPlugin? _calendarPlugin;

  factory CalendarUtil() {
    return _instance;
  }

  CalendarUtil._internal();

  static void init() {
    _calendarPlugin = DeviceCalendarPlugin();
  }

  Future<timezone.Location> getLocalTimeZone() async {
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      return timezone.getLocation(timeZoneName);
    } catch (e) {
      print("Error getting local time zone: $e");
      return timezone.getLocation('UTC');
    }
  }

  Future<bool> enableCalendarAccess() async {
    try {
      if (_calendarPlugin == null) {
        print("Attempting to initialize _calendarPlugin");
        _calendarPlugin = DeviceCalendarPlugin();
      }

      final permissionsResult = await _calendarPlugin!.hasPermissions();
      if (permissionsResult == null) {
        print("hasPermissions returned null");
        return false;
      }

      if (!permissionsResult.isSuccess) {
        print("Failed to check permissions: ${permissionsResult.errors}");
        return false;
      }

      if (permissionsResult.data == false) {
        final requestResult = await _calendarPlugin!.requestPermissions();
        if (requestResult == null) {
          print("requestPermissions returned null");
          return false;
        }
        if (!requestResult.isSuccess) {
          print("Failed to request permissions: ${requestResult.errors}");
          return false;
        }
        return requestResult.data ?? false;
      }

      return true;
    } catch (e, stackTrace) {
      print("Exception in enableCalendarAccess: $e");
      print("Stack trace: $stackTrace");
      return false;
    }
  }

  Future<List<Calendar>> getCalendars() async {
    bool hasAccess = await enableCalendarAccess();
    if (!hasAccess) return [];

    final calendarsResult = await _calendarPlugin!.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      return calendarsResult.data!;
    }
    return [];
  }

  // DateTime parseTime(String timeStr, DateTime baseDate) {
  //   final timeFormat = RegExp(r'^(\d{1,2})\s*(am|pm)$', caseSensitive: false);
  //   final match = timeFormat.firstMatch(timeStr.trim().toLowerCase());

  //   if (match != null) {
  //     int hour = int.parse(match.group(1)!);
  //     String period = match.group(2)!;

  //     if (period == 'pm' && hour != 12) {
  //       hour += 12;
  //     } else if (period == 'am' && hour == 12) {
  //       hour = 0;
  //     }

  //     return DateTime(baseDate.year, baseDate.month, baseDate.day, hour);
  //   } else {
  //     throw FormatException("Invalid time format: $timeStr");
  //   }
  // }

  Future<bool> createEvent(String title, DateTime startsAt, int durationMinutes,
      {String? description}) async {
    print("inoming data");
    print(title);

    bool hasAccess = await enableCalendarAccess();
    if (!hasAccess) return false;
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print("currentTimeZone: $currentTimeZone");
    final currentLocation = timeZoneDatabase.locations[currentTimeZone];
    print("currentLocation: $currentLocation");
    String calendarId = SharedPreferencesUtil().calendarId;
    var event = Event(
      calendarId,
      title: title,
      description: description,
      start: TZDateTime.from(startsAt, currentLocation!),
      end: TZDateTime.from(
          startsAt.add(Duration(minutes: durationMinutes)), currentLocation),
      availability: Availability.Tentative,
    );
    final createResult = await _calendarPlugin!.createOrUpdateEvent(event);
    if (createResult?.isSuccess == true) {
      debugPrint('Event created successfully ${createResult!.data}');
      return true;
    } else {
      debugPrint('Failed to create event: ${createResult!.errors}');
    }
    return false;
  }
}
