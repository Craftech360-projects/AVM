import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/transcript_segment.dart';
import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/utils/audio/wav_bytes.dart';
import 'package:capsoul/utils/ble/communication.dart';

part 'speech_profile_event.dart';
part 'speech_profile_state.dart';

class SpeechProfileBloc extends Bloc<SpeechProfileEvent, SpeechProfileState> {
  SpeechProfileBloc() : super(SpeechProfileState.initial()) {
    on<SampleAudioRecorded>((event, emit) {
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

      int percentageCompleted = (wordsCount ~/ targetWordsCount) * 100;
      if (percentageCompleted == 100) {
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
