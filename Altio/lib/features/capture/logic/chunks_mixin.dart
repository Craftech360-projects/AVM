import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:altio/backend/api_requests/api/other.dart';
import 'package:altio/backend/api_requests/api/server.dart';
import 'package:altio/backend/database/transcript_segment.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/utils/audio/wav_bytes.dart';
import 'package:altio/utils/ble/communication.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:tuple/tuple.dart';

mixin AudioChunksMixin {
  Future<StreamSubscription?> initiateChunksProcessing(
    String deviceId,
    BleAudioCodec deviceCodec,
    WavBytesUtil? audioStorage,
    Function(List<TranscriptSegment>, List<List<int>>) onNewSegments,
    Function(bool) setIsTranscribing,
    InternetStatus? internetStatus,
  ) async {
    // BleAudioCodec codec = await getAudioCodec(deviceId);
    // if (codec == BleAudioCodec.unknown) {
    //   //disconnect and show error
    // }

    WavBytesUtil toProcessBytes2 = WavBytesUtil(codec: deviceCodec);
    return await getBleAudioBytesListener(
      deviceId,
      onAudioBytesReceived: (List<int> value) async {
        if (value.isEmpty) return;

        toProcessBytes2.storeFramePacket(value);
        audioStorage!.storeFramePacket(value);
        if (toProcessBytes2.hasFrames() &&
            toProcessBytes2.frames.length % 3000 == 0) {
          if (internetStatus == InternetStatus.disconnected) {
            return;
          }
          if (await WavBytesUtil.tempWavExists()) {
            return; // wait til that one is fully processed
          }

          Tuple2<File, List<List<int>>> data =
              await toProcessBytes2.createWavFile(filename: 'temp.wav');
          try {
            setIsTranscribing(true);
            List<TranscriptSegment> newSegments =
                await _processFileToTranscript(data.item1);
            setIsTranscribing(false);
            onNewSegments(newSegments, data.item2);
          } on Exception {
            toProcessBytes2.insertAudioBytes(data.item2);
          }
          await WavBytesUtil.deleteTempWav();
        }
      },
    );
  }

  Future<List<TranscriptSegment>> _processFileToTranscript(File f) async {
    _printFileSize(f);
    if (SharedPreferencesUtil().useTranscriptServer) {
      return await transcribe(f);
    } else {
      return await deepgramTranscribe(f);
    }
  }

  void _printFileSize(File file) async {
    int bytes = await file.length();
    var i = (log(bytes) / log(1024)).floor();
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var size = '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
    debugPrint('File size: $size');
  }
}
