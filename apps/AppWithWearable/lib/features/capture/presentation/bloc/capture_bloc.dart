import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/pages/capture/logic/websocket_mixin.dart';
import 'package:friend_private/src/features/live_transcript/data/datasources/ble_connection_datasource.dart';
import 'package:friend_private/utils/audio/wav_bytes.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:friend_private/utils/enums.dart';
import 'package:friend_private/utils/websockets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:uuid/uuid.dart';

part 'capture_event.dart';
part 'capture_state.dart';

class CaptureBloc extends Bloc<CaptureEvent, CaptureState> with WebSocketMixin {
  CaptureBloc() : super(const CaptureState()) {
    // on<InitiateWebSocket>((event, emit) async {
    //   final audioCodec = event.audioCodec;
    //   final sampleRate = event.sampleRate;
    //   BleAudioCodec codec = audioCodec ??
    //       (state.btDevice?.id == null
    //           ? BleAudioCodec.pcm8
    //           : await getAudioCodec(event.btDevice!.id));
    //   await initWebSocket(
    //     codec: codec,
    //     sampleRate: sampleRate,
    //     onConnectionSuccess: () {
    //       if (state.segments.isNotEmpty) {
    //         // means that it was a reconnection, so we need to reset
    //         state.copyWith(segments: null);
    //         state.copyWith(
    //             secondsMissedOnReconnect: (DateTime.now()
    //                 .difference(state.firstStreamReceivedAt!)
    //                 .inSeconds));
    //       }
    //     },
    //     onConnectionFailed: (err) {},
    //     onConnectionClosed: (int? closeCode, String? closeReason) {},
    //     onConnectionError: (err) {},
    //     onMessageReceived: (List<TranscriptSegment> newSegments) {
    //       if (newSegments.isEmpty) return;

    //       if (state.segments.isEmpty) {
    //         state.audioStorage?.removeFramesRange(
    //             fromSecond: 0, toSecond: newSegments[0].start.toInt());
    //         state.copyWith(firstStreamReceivedAt: DateTime.now());
    //       }
    //       state.copyWith(streamStartedAtSecond: newSegments[0].start);

    //       TranscriptSegment.combineSegments(
    //         segments,
    //         newSegments,
    //         toRemoveSeconds: streamStartedAtSecond ?? 0,
    //         toAddSeconds: secondsMissedOnReconnect ?? 0,
    //       );
    //       triggerTranscriptSegmentReceivedEvents(newSegments, conversationId,
    //           sendMessageToChat: sendMessageToChat);
    //       SharedPreferencesUtil().transcriptSegments = segments;
    //       setHasTranscripts(true);
    //       debugPrint('Memory creation timer restarted');
    //       _memoryCreationTimer?.cancel();
    //       _memoryCreationTimer = Timer(
    //           const Duration(seconds: quietSecondsForMemoryCreation),
    //           () => _createMemory());
    //       currentTranscriptStartedAt ??= DateTime.now();
    //       currentTranscriptFinishedAt = DateTime.now();
    //     },
    //   );
    // });

  }
}
