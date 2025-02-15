import 'dart:async';

import 'package:altio/features/capture/logic/wals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class ServiceManager {
  late IWalService _wal;

  static ServiceManager? _instance;

  static ServiceManager _create() {
    ServiceManager sm = ServiceManager();

    sm._wal = WalService();

    return sm;
  }

  static ServiceManager instance() {
    if (_instance == null) {
      throw Exception("Service manager is not initiated");
    }

    return _instance!;
  }

  IWalService get wal => _wal;

  static void init() {
    if (_instance != null) {
      throw Exception("Service manager is initiated");
    }
    _instance = ServiceManager._create();
  }

  Future<void> start() async {
    _wal.start();
  }

  void deinit() async {
    await _wal.stop();
  }
}

enum BackgroundServiceStatus {
  initiated,
  running,
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
Future onStart(ServiceInstance service) async {
  // Recorder

  service.on('recorder.stop').listen((event) async {
    service.invoke("recorder.ui.stateUpdate", {"state": 'stopped'});
  });

  service.on('stop').listen((event) async {
    service.invoke("recorder.ui.stateUpdate", {"state": 'stopped'});
    await service.stopSelf();
  });

  // watchdog
  var pongAt = DateTime.now();
  service.on('pong').listen((event) async {
    pongAt = DateTime.now();
  });
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (pongAt.isBefore(DateTime.now().subtract(const Duration(seconds: 15)))) {
      // retire

      service.invoke("recorder.ui.stateUpdate", {"state": 'stopped'});
      await service.stopSelf();
      return;
    }
    service.invoke("ui.ping");
  });
}

class BackgroundService {
  late FlutterBackgroundService _service;
  BackgroundServiceStatus? _status;

  BackgroundServiceStatus? get status => _status;

  Future<void> init() async {
    _service = FlutterBackgroundService();
    _status = BackgroundServiceStatus.initiated;

    await _service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
      ),
    );

    _status = BackgroundServiceStatus.initiated;
  }

  Future<void> ensureRunning() async {
    await init();
    await start();
  }

  Future<void> start() async {
    await _service.startService();

    // status
    if (await _service.isRunning()) {
      _status = BackgroundServiceStatus.running;
    }

    // heartbeat
    _service.on('ui.ping').listen((event) {
      _service.invoke("pong");
    });
  }

  void stop() {
    debugPrint("invoke stop");
    _service.invoke("stop");
  }
}
