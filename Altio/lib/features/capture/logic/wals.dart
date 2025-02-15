import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:altio/backend/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const chunkSizeInSeconds = 60;
const flushIntervalInSeconds = 90;

abstract class IWalSyncProgressListener {
  void onWalSyncedProgress(double percentage); // 0..1
}

mixin IWalSyncListener {
  void onMissingWalUpdated();
  bool isInternetAvailable();
}

abstract class IWalServiceListener with IWalSyncListener {
  void onStatusChanged(WalServiceStatus status);
}

abstract class IWalSync {
  Future<List<Wal>> getMissingWals();
  Future deleteWal(Wal wal);
  // Future<SyncLocalFilesResponse?> syncAll({IWalSyncProgressListener? progress});
  // Future<SyncLocalFilesResponse?> syncWal(
  //     {required Wal wal, IWalSyncProgressListener? progress});

  void start();
  Future stop();
}

abstract class IWalService {
  void start();
  Future stop();

  void subscribe(IWalServiceListener subscription, Object context);
  void unsubscribe(Object context);

  WalSyncs getSyncs();
}

enum WalServiceStatus {
  init,
  ready,
  stop,
}

enum WalStatus {
  inProgress,
  miss,
  synced,
  corrupted,
}

enum WalStorage {
  mem,
  disk,
  sdcard,
}

class Wal {
  int timerStart; // in seconds
  String codec;
  int channel;
  int sampleRate;
  int seconds;
  String device;

  WalStatus status;
  WalStorage storage;

  String? filePath;
  List<List<int>> data = [];
  int storageOffset = 0;
  int storageTotalBytes = 0;
  int fileNum = 1;

  bool isSyncing = false;
  DateTime? syncStartedAt;
  int? syncEtaSeconds;

  String get id => '${device}_$timerStart';

  Wal(
      {required this.timerStart,
      this.codec = "opus",
      this.sampleRate = 16000,
      this.channel = 1,
      this.status = WalStatus.inProgress,
      this.storage = WalStorage.mem,
      this.filePath,
      this.seconds = chunkSizeInSeconds,
      this.device = "phone",
      this.storageOffset = 0,
      this.storageTotalBytes = 0,
      this.fileNum = 1,
      this.data = const []});

  factory Wal.fromJson(Map<String, dynamic> json) {
    return Wal(
      timerStart: json['timer_start'],
      codec: json['codec'],
      channel: json['channel'],
      sampleRate: json['sample_rate'],
      status:
          WalStatus.values.asNameMap()[json['status']] ?? WalStatus.inProgress,
      storage: WalStorage.values.asNameMap()[json['storage']] ?? WalStorage.mem,
      filePath: json['file_path'],
      seconds: json['seconds'] ?? chunkSizeInSeconds,
      device: json['device'] ?? "phone",
      storageOffset: json['storage_offset'] ?? 0,
      storageTotalBytes: json['storage_total_bytes'] ?? 0,
      fileNum: json['file_num'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timer_start': timerStart,
      'codec': codec,
      'channel': channel,
      'sample_rate': sampleRate,
      'status': status.name,
      'storage': storage.name,
      'file_path': filePath,
      'seconds': seconds,
      'device': device,
      'storage_offset': storageOffset,
      'storage_total_bytes': storageTotalBytes,
      'file_num': fileNum,
    };
  }

  static List<Wal> fromJsonList(List<dynamic> jsonList) =>
      jsonList.map((e) => Wal.fromJson(e)).toList();

  String getFileName() {
    return "audio_${device.replaceAll(RegExp(r'[^a-zA-Z0-9]'), "").toLowerCase()}_${codec}_${sampleRate}_${channel}_$timerStart.bin";
  }
}

class LocalWalSync implements IWalSync {
  List<Wal> _wals = const [];

  final HashSet<int> _syncFrameSeq = HashSet();

  Timer? _flushingTimer;

  IWalSyncListener listener;

  LocalWalSync(this.listener);

  @override
  void start() {
    _wals = SharedPreferencesUtil().wals;
    debugPrint("wal service start: ${_wals.length}");
    // Change flush interval to 60 seconds
    _flushingTimer = Timer.periodic(const Duration(seconds: 60), (t) async {
      debugPrint('Periodic flush triggered');
      await _flush();
    });
  }

  @override
  Future stop() async {
    _flushingTimer?.cancel();
    await _flush(); // Ensure all data is saved before stopping
    activeWal = null;

    _syncFrameSeq.clear();
    _wals = [];
  }

  Future _flush() async {
    if (activeWal == null) return;

    // Check internet connectivity before flushing
    if (listener.isInternetAvailable()) {
      debugPrint('Internet available, skipping flush.');
      return;
    }

    debugPrint('=== Flushing WAL Data to Disk ===');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String filePath =
          '${directory.path}/audio_phone_opus_16000_1_$timestamp.bin';

      List<int> data = [];
      for (var frame in activeWal!.data) {
        var frameBytes = frame.sublist(3);
        var lengthBytes =
            Uint32List.fromList([frameBytes.length]).buffer.asUint8List();
        data.addAll(lengthBytes);
        data.addAll(frameBytes);
      }

      final file = File(filePath);
      if (data.isNotEmpty) {
        await file.writeAsBytes(data);
        debugPrint('WAL data saved to: $filePath');
        debugPrint('File size: ${file.lengthSync()} bytes');
      } else {
        debugPrint('No data to write, skipping file creation');
      }

      activeWal!.data.clear();
    } on Exception catch (e) {
      debugPrint('Error writing WAL to disk: $e');
    }
  }

  Future<bool> _deleteWal(Wal wal) async {
    if (wal.filePath != null && wal.filePath!.isNotEmpty) {
      try {
        final file = File(wal.filePath!);
        if (file.existsSync()) {
          await file.delete();
        }
      } on Exception catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }

    _wals.removeWhere((w) => w.id == wal.id);
    return true;
  }

  @override
  Future deleteWal(Wal wal) async {
    await _deleteWal(wal);
    listener.onMissingWalUpdated();
  }

  @override
  Future<List<Wal>> getMissingWals() async {
    return _wals.where((w) => w.status == WalStatus.miss).toList();
  }

  Wal? activeWal; // Store reference to the active WAL

  void onByteStream(List<int> value) async {
    if (value.isEmpty) return;

    // Check if internet is available, skip storing if online
    if (listener.isInternetAvailable()) {
      return;
    }

    // If no WAL is active, create one
    if (activeWal == null) {
      var timerStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      activeWal = Wal(
        timerStart: timerStart,
        data: [],
        storage: WalStorage.mem,
        status: WalStatus.inProgress,
      );
      _wals.add(activeWal!);
    }

    // Append incoming data to the active WAL
    activeWal!.data.add(List<int>.from(value));
  }

  void onBytesSync(List<int> value) {
    var head = value.sublist(0, 3);
    var seq = Uint8List.fromList(head..add(0)).buffer.asByteData().getInt32(0);
    _syncFrameSeq.add(seq);
  }
}

class WalSyncs implements IWalSync {
  late LocalWalSync phoneSync;
  LocalWalSync get phone => phoneSync;

  IWalSyncListener listener;

  WalSyncs(this.listener) {
    phoneSync = LocalWalSync(listener);
  }

  @override
  Future deleteWal(Wal wal) async {
    await phoneSync.deleteWal(wal);
  }

  @override
  Future<List<Wal>> getMissingWals() async {
    List<Wal> wals = [];

    wals.addAll(await phoneSync.getMissingWals());
    return wals;
  }

  @override
  void start() {
    phoneSync.start();
  }

  @override
  Future stop() async {
    await phoneSync.stop();
  }
}

class WalService implements IWalService, IWalSyncListener {
  final Map<Object, IWalServiceListener> subscriptions = {};
  final WalServiceStatus status = WalServiceStatus.init;
  WalServiceStatus get walstatus => status;

  late WalSyncs syncs;
  WalSyncs get walsyncs => syncs;

  WalService() {
    syncs = WalSyncs(this);
  }

  @override
  void subscribe(IWalServiceListener subscription, Object context) {
    subscriptions.remove(context.hashCode);
    subscriptions.putIfAbsent(context.hashCode, () => subscription);

    // retains
    subscription.onStatusChanged(status);
  }

  @override
  void unsubscribe(Object context) {
    subscriptions.remove(context.hashCode);
  }

  @override
  void start() {
    // _syncs.start();
    // _status = WalServiceStatus.ready;
  }

  @override
  Future stop() async {
    // await _syncs.stop();

    // _status = WalServiceStatus.stop;
    // _onStatusChanged(_status);
    // _subscriptions.clear();
  }

  void onStatusChanged(WalServiceStatus status) {
    for (var s in subscriptions.values) {
      s.onStatusChanged(status);
    }
  }

  @override
  WalSyncs getSyncs() {
    return syncs;
  }

  @override
  void onMissingWalUpdated() {
    for (var s in subscriptions.values) {
      s.onMissingWalUpdated();
    }
  }

  @override
  bool isInternetAvailable() {
    // TODO: implement isInternetAvailable
    throw UnimplementedError();
  }
}
