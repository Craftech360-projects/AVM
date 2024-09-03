import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  MemoryBloc() : super(MemoryState.initial()) {
    on<DisplayedMemory>(_displayedMemory);
    on<DeletedMemory>(_deletedMemory);
    on<SearchMemory>(_searchMemory);
    on<UpdatedMemory>(_updatedMemory);
    on<MemoryIndexChanged>(_memoryChanged);
  }
  FutureOr<void> _memoryChanged(event, emit) async {
    final int? newIndex = await event.memoryIndex;
    emit(
      state.copyWith(memoryIndex: newIndex, status: MemoryStatus.success),
    );
  }

  FutureOr<void> _updatedMemory(event, emit) async {
    MemoryProvider().updateMemoryStructured(event.structured);

    emit(state.copyWith(
      status: MemoryStatus.success,
    ));
  }

  FutureOr<void> _deletedMemory(event, emit) {
    try {
      MemoryProvider().deleteMemory(event.memory);
      _displayedMemory;
    } catch (error) {
      emit(
        state.copyWith(
          status: MemoryStatus.failure,
          failure: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _displayedMemory(event, emit) async {
    emit(
      state.copyWith(
        status: MemoryStatus.loading,
      ),
    );

    try {
      final allMemories = MemoryProvider().getMemories();
      print('>>> bloc all memories$allMemories');
      final nonDiscardedMemories =
          allMemories.where((memory) => !memory.discarded).toList();
      final memoriesToConsider =
          event.isNonDiscarded ? nonDiscardedMemories : allMemories;
      memoriesToConsider.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      List<Memory> mostRecentMemory =
          memoriesToConsider.isNotEmpty ? memoriesToConsider : [];
      print("mostRecentMemory $mostRecentMemory");
      emit(
        state.copyWith(
          status: MemoryStatus.success,
          memories: mostRecentMemory,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MemoryStatus.failure,
          failure: error.toString(),
        ),
      );
    }
  }

  FutureOr<void> _searchMemory(SearchMemory event, Emitter<MemoryState> emit) {
    try {
      print('search event triggered ${event.query}');
      if (event.query.isEmpty) {
        print('original runs1 ${state.memories}');

        add(const DisplayedMemory());
      } else {
        final filteredMemories = state.memories.where((memory) {
          final searchContent = '${memory.transcript}'
                  '${memory.structured.target?.title}'
                  '${memory.structured.target?.overview}'
              .toLowerCase();
          return searchContent.contains(event.query.toLowerCase());
        }).toList();

        emit(
          state.copyWith(
            status: MemoryStatus.success,
            memories: filteredMemories,
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: MemoryStatus.failure,
          failure: error.toString(),
        ),
      );
    }
  }
}
