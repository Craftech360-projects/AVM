import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const chunkSizeInSeconds = 60; // Duration of each chunk in seconds
const flushIntervalInSeconds = 90; // Interval to flush data to disk

/// Represents an audio data chunk with metadata for synchronization and storage.
class Wal {
  final int timerStart; // Start time in seconds
  final String codec; // Audio codec (e.g., opus)
  final int sampleRate; // Audio sample rate
  final int channel; // Audio channel count
  final String device; // Device identifier

  List<List<int>> data; // Buffered audio frames
  String? filePath; // Path to the stored file

  Wal({
    required this.timerStart,
    required this.codec,
    required this.sampleRate,
    required this.channel,
    required this.device,
    this.data = const [],
    this.filePath,
  });

  /// Generates a unique filename for the Wal object.
  String getFileName() {
    return "audio_${device}_${codec}_${sampleRate}_${channel}_$timerStart.bin";
  }
}

/// Manages audio data synchronization and storage.
class LocalWalSync {
  final List<Wal> _wals = []; // List of Wal objects
  final List<List<int>> _frames = []; // Buffer for incoming audio frames
  Timer? _chunkingTimer; // Timer for periodic chunking
  Timer? _flushingTimer; // Timer for periodic flushing

  /// Starts the synchronization service with periodic chunking and flushing.
  void start() {
    _chunkingTimer = Timer.periodic(
      const Duration(seconds: chunkSizeInSeconds),
      (_) => _chunk(),
    );

    _flushingTimer = Timer.periodic(
      const Duration(seconds: flushIntervalInSeconds),
      (_) => _flush(),
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
  }

  /// Converts buffered frames into `Wal` chunks.
  Future<void> _chunk() async {
    if (_frames.isEmpty) {
      debugPrint("No frames to process.");
      return;
    }

    const framesPerSecond = 100; // Assuming 100 frames per second
    final chunkSize = framesPerSecond * chunkSizeInSeconds;

    while (_frames.length >= chunkSize) {
      // Extract a chunk of frames
      final chunk = _frames.sublist(0, chunkSize);
      _frames.removeRange(0, chunkSize);

      // Create a new Wal object
      final timerStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final wal = Wal(
        timerStart: timerStart,
        codec: "opus",
        sampleRate: 16000,
        channel: 1,
        device: "phone",
        data: chunk,
      );

      _wals.add(wal);
      debugPrint("Chunk created: ${wal.getFileName()}");
    }
  }

  /// Writes all buffered Wal objects to disk.
  Future<void> _flush() async {
    if (_wals.isEmpty) {
      debugPrint("No Wals to flush.");
      return;
    }

    final directory = await getApplicationDocumentsDirectory();

    for (var wal in _wals) {
      if (wal.filePath != null) continue; // Skip already flushed Wals

      final filePath = '${directory.path}/${wal.getFileName()}';
      final file = File(filePath);

      // Flatten and write the chunked data to the file
      final flattenedData = wal.data.expand((frame) => frame).toList();
      try {
        await file.writeAsBytes(flattenedData);
        wal.filePath = filePath;
        debugPrint("Flushed to disk: $filePath");
      } catch (e) {
        debugPrint("Error writing to disk: $e");
      }
    }

    // Remove flushed Wals
    _wals.removeWhere((wal) => wal.filePath != null);
  }
}

/// Provides a high-level service for managing Wal synchronization.
class WalService {
  final LocalWalSync localWalSync = LocalWalSync();

  /// Starts the synchronization service.
  void start() {
    localWalSync.start();
    debugPrint("WalService started.");
  }

  /// Stops the synchronization service.
  Future<void> stop() async {
    await localWalSync.stop();
    debugPrint("WalService stopped.");
  }

  /// Provides access to the LocalWalSync instance.
  LocalWalSync getSyncs() {
    return localWalSync;
  }
}
