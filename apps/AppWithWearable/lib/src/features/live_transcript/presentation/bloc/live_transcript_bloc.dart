import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'live_transcript_event.dart';
part 'live_transcript_state.dart';

class LiveTranscriptBloc extends Bloc<LiveTranscriptEvent, LiveTranscriptState> {
  LiveTranscriptBloc() : super(LiveTranscriptInitial()) {
    on<LiveTranscriptEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
