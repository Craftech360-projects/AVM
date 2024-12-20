import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  MemoryBloc() : super(MemoryInitial()) {
    on<MemoryEvent>((event, emit) {
      // implement event handler
    });
  }
}
