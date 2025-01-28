import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const chunkSizeInSeconds = 60; // Duration of each chunk in seconds
const flushIntervalInSeconds = 90; // Interval to flush data to disk

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

  getFileName() {
    return "audio_${device.replaceAll(RegExp(r'[^a-zA-Z0-9]'), "").toLowerCase()}_${codec}_${sampleRate}_${channel}_$timerStart.bin";
  }
}

class LocalWalSync {
  final List<Wal> _wals = []; // List of Wal objects
  final List<List<int>> _frames = []; // Buffer for incoming audio frames
  final HashSet<int> _syncFrameSeq =
      HashSet<int>(); // Tracks processed frame sequences

  Timer? _chunkingTimer; // Timer for periodic chunking
  Timer? _flushingTimer; // Timer for periodic flushing

  /// Get the total missing WAL seconds based on the buffered Wals.
  int get missingWalSeconds {
    const framesPerSecond = 100; // Assuming 100 frames per second
    int totalFrames = _frames.length;
    return (totalFrames / framesPerSecond).floor();
  }

  /// Determines if WAL synchronization is supported.
  bool get isWalSupported {
    // Adjust the logic based on your application's needs.
    return true; // For example, always return true if synchronization is active.
  }

  /// Starts the synchronization service with delayed synchronization logic.
  void start() {
    _chunkingTimer = Timer.periodic(
      const Duration(seconds: chunkSizeInSeconds),
      (_) {
        debugPrint("Chunking timer triggered.");
        _chunk();
      },
    );

    _flushingTimer = Timer.periodic(
      const Duration(seconds: flushIntervalInSeconds),
      (_) {
        debugPrint("Flushing timer triggered.");
        _flush();
      },
    );
    debugPrint("LocalWalSync started.");
  }

  /// Stops all timers and processes remaining data.
  Future<void> stop() async {
    _chunkingTimer?.cancel();
    _flushingTimer?.cancel();

    await _chunk();
    await _flush();
    _frames.clear();
    _wals.clear();

    debugPrint("LocalWalSync stopped.");
  }

  /// Buffers incoming audio data.
  void onByteStream(List<int> value) {
    if (value.isEmpty) return;
    _frames.add(value);
    debugPrint("Accumulated frames: ${_frames.length}");
  }

  void onBytesSync(List<int> value) {
    var head = value.sublist(0, 3);
    print("Syncing frame head: $head");
    var seq = Uint8List.fromList(head..add(0)).buffer.asByteData().getInt32(0);
    debugPrint("Syncing frame: $seq");
    _syncFrameSeq.add(seq);
  }

  Future<void> _chunk() async {
    if (_frames.isEmpty) {
      debugPrint("No frames to process.");
      return;
    }

    const framesPerSecond = 100; // Assuming 100 frames per second
    const chunkSize =
        framesPerSecond * chunkSizeInSeconds; // Number of frames per chunk

    debugPrint(
        "Frames accumulated: ${_frames.length}, Chunk size required: $chunkSize");

    var timerEnd = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    var high = _frames.length;
    while (high > 0) {
      var low = high - chunkSize;
      if (low < 0) low = 0;

      var chunk = _frames.sublist(low, high);

      // Check if the chunk is being created
      debugPrint(
          "Creating chunk of size ${chunk.length}, High: $high, Low: $low");

      // Add the chunk to the _wals list
      _wals.add(Wal(
        timerStart: timerEnd - (high - low) ~/ framesPerSecond,
        data: chunk,
      ));

      debugPrint("Added Wal to _wals: ${_wals.length}");

      // Safely remove processed frames from the _frames list, ensuring we don't attempt to remove more frames than available
      var framesToRemove = chunk.length;
      _frames.removeRange(0, framesToRemove);

      // Update the timerEnd for the next chunk
      timerEnd -= chunkSizeInSeconds;

      // Set high to the low value to process the next chunk
      high = low;
    }

    // Debugging: Print remaining frames
    debugPrint("Remaining frames: ${_frames.length}");
  }

  /// Writes all buffered Wal objects to disk.
  Future<void> _flush() async {
    if (_wals.isEmpty) {
      debugPrint("No Wals to flush.");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    debugPrint("Flushing ${_wals.length} Wals to disk.");
    for (var wal in _wals) {
      if (wal.filePath != null) continue; // Skip already flushed Wals

      final filePath = '${directory.path}/${wal.getFileName()}';
      final file = File(filePath);

      final flattenedData = wal.data.expand((frame) => frame).toList();
      try {
        await file.writeAsBytes(flattenedData);
        wal.filePath = filePath;
        debugPrint("Flushed Wal to disk: ${wal.id} at $filePath");
      } catch (e) {
        debugPrint("Error writing Wal to disk: $e");
      }
    }
    // Check how many Wals are remaining after the flush
    debugPrint("no of  Wals in _wals: ${_wals.length}");
    // Remove flushed Wals from _wals
    _wals.removeWhere((wal) => wal.filePath != null);
    debugPrint("Removed flushed Wals from _wals.");
    // Check how many Wals are remaining after the flush
    debugPrint("Remaining Wals in _wals: ${_wals.length}");
  }
}
