import 'dart:async';
import 'dart:io';

import 'package:altio/backend/preferences.dart';
import 'package:altio/utils/other/notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeBackgroundService({bool isStream = false}) async {
  final service = FlutterBackgroundService();
  createNotification(
    title: 'Capsaul is quietly listening',
    body: 'Capturing every word and transcribing with ease.',
  );

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (service) {
        onStart(service, isStream);
      },
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: (service) {
        onStart(service, isStream);
      },
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: 'channel',
    ),
  );
  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service, bool isStream) async {
  if (isStream) {
    await streamRecording(service);
  } else {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await service.setForegroundNotificationInfo(
          title: 'Altio is running in background',
          content:
              'Altio is listening and transcribing your conversations in the background',
        );
      }
    }
    int count = 0;
    await SharedPreferencesUtil.init();
    var record = AudioRecorder();
    var path = await getApplicationDocumentsDirectory();
    var files = Directory(path.path).listSync();
    for (var file in files) {
      if (file.path.contains('recording_') &&
          !file.path.contains('recording_0')) {
        file.deleteSync();
      }
    }
    var filePath = '${path.path}/recording_$count.wav';
    service.invoke("stateUpdate", {"state": 'recording'});
    await record.start(const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath);
    // timerUpdate is only invoked on Android
    service.on("timerUpdate").listen((event) async {
      if (event!["time"] == '0') {
        if (await record.isRecording()) {
          await record.stop();
          await record.dispose();
        }
      }
      if (event["time"] == '30') {
        var paths = SharedPreferencesUtil().recordingPaths;
        SharedPreferencesUtil().recordingPaths = [...paths, filePath];
        count++;
        filePath = '${path.path}/recording_$count.wav';
        record = AudioRecorder();
        await record.start(const RecordConfig(encoder: AudioEncoder.wav),
            path: filePath);
      }
    });
    service.on("stop").listen((event) async {
      await record.stop();
      await record.dispose();
      await service.stopSelf();
    });
  }
}

Future streamRecording(ServiceInstance service) async {
  var record = AudioRecorder();
  var path = await getApplicationDocumentsDirectory();
  int count = 0;
  var filePath = '${path.path}/recording_$count.m4a';
  service.invoke("stateUpdate", {"state": 'recording'});
  var stream = await record
      .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits));
  var audioData = <int>[];
  var file = File(filePath);
  stream.listen((data) async {
    audioData.addAll(data);
    file.writeAsBytesSync(data, mode: FileMode.append);
  });
  service.on("stop").listen((event) async {
    await record.stop();
    await record.dispose();
    await service.stopSelf();
  });
}
