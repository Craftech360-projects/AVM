import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/transcript_segment.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/src/features/live_transcript/data/datasources/ble_connection_datasource.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/utils/audio/wav_bytes.dart';
import 'package:friend_private/utils/ble/communication.dart';
import 'package:meta/meta.dart';

part 'speech_profile_event.dart';
part 'speech_profile_state.dart';

class SpeechProfileBloc extends Bloc<SpeechProfileEvent, SpeechProfileState> {
  SpeechProfileBloc() : super(SpeechProfileState.initial()) {
//! processing voice and generating text from segments
//     onMessageReceived: (List<TranscriptSegment> newSegments) {
//   if (newSegments.isEmpty) return;
//   if (segments.isEmpty) {
//     audioStorage.removeFramesRange(fromSecond: 0, toSecond: newSegments[0].start.toInt());
//   }
//   streamStartedAtSecond ??= newSegments[0].start;

//   TranscriptSegment.combineSegments(
//     segments,
//     newSegments,
//     toRemoveSeconds: streamStartedAtSecond ?? 0,
//   );
//   updateProgressMessage();
//   _validateSingleSpeaker();
//   _handleCompletion(isFromOnboarding); // Handles completion logic
//   notifyInfo('SCROLL_DOWN');
//   debugPrint('Memory creation timer restarted');
// }
//! saving and uploading profile
// Future finalize(bool isFromOnboarding) async {
//   if (uploadingProfile || profileCompleted) return;

//   String text = segments.map((e) => e.text).join(' ').trim();
//   if (text.split(' ').length < (targetWordsCount / 2)) {
//     // 25 words
//     notifyError('TOO_SHORT');
//   }

//   uploadingProfile = true;
//   notifyListeners();
//   await webSocketProvider?.closeWebSocketWithoutReconnect('finalizing');
//   forceCompletionTimer?.cancel();
//   connectionStateListener?.cancel();
//   _bleBytesStream?.cancel();

//   updateLoadingText('Memorizing your voice...');
//   List<List<int>> raw = List.from(audioStorage.rawPackets);
//   var data = await audioStorage.createWavFile(filename: 'speaker_profile.wav');
//   try {
//     await uploadProfile(data.item1);  // Uploads WAV file
//     await uploadProfileBytes(raw, duration);  // Uploads raw bytes
//   } catch (e) {}

//   updateLoadingText('Personalizing your experience...');
//   SharedPreferencesUtil().hasSpeakerProfile = true;

//   if (isFromOnboarding) {
//     await createMemory();  // Calls memory creation after upload
//     captureProvider?.clearTranscripts();
//   }

//   await captureProvider?.resetState(restartBytesProcessing: true);
//   uploadingProfile = false;
//   profileCompleted = true;
//   text = '';
//   updateLoadingText("You're all set!");
//   notifyListeners();
// }
//!storing the processed transcript as a memory
// Future<bool?> createMemory({bool forcedCreation = false}) async {
//   File? file;
//   if (audioStorage.frames.isNotEmpty == true) {
//     try {
//       file = (await audioStorage.createWavFile(removeLastNSeconds: 0)).item1;
//       uploadFile(file);
//     } catch (e) {
//       print("creating and uploading file error: $e");
//     }
//   }

//   memory = await processTranscriptContent(
//     segments: segments,
//     startedAt: null,
//     finishedAt: null,
//     geolocation: null,
//     photos: [],
//     triggerIntegrations: true,
//     language: SharedPreferencesUtil().recordingsLanguage,
//     source: 'speech_profile_onboarding',
//   );
//   debugPrint(memory.toString());

//   if (memory == null && (segments.isNotEmpty)) {
//     memory = ServerMemory(
//       id: const Uuid().v4(),
//       createdAt: DateTime.now(),
//       structured: Structured('', '', emoji: '⛓️‍💥', category: 'other'),
//       discarded: true,
//       transcriptSegments: segments,
//       failed: true,
//       source: segments.isNotEmpty ? MemorySource.friend : MemorySource.openglass,
//       language: segments.isNotEmpty ? SharedPreferencesUtil().recordingsLanguage : null,
//     );
//     SharedPreferencesUtil().addFailedMemory(memory!);
//   }

//   notifyListeners();
//   return true;
// }
    on<SampleAudioRecorded>((event, emit) {
      // Check if audio is available at shared preferences
      // If available, send to BE, otherwise record audio and save to shared pref

      String text = event.segments.map((e) => e.text).join(' ').trim();
      int wordsCount = text.split(' ').length;
      const int targetWordsCount = 50; 
      String message = 'Keep speaking until you get 100%.';
      if (wordsCount > 40) {
        message = 'So close, just a little more';
      } else if (wordsCount > 25) {
        message = 'Great job, you are almost there';
      } else if (wordsCount > 10) {
        message = 'Keep going, you are doing great';
      }
      
      int percentageCompleted = (wordsCount ~/ targetWordsCount)*100;
if(percentageCompleted==100){
  //save isAvailable=ture to shared pref
  //send recording file to BE
}
      emit(state.copyWith(
        message: message,
        text: text,
        percentageCompleted: percentageCompleted,
      ));
    });
  }
}
