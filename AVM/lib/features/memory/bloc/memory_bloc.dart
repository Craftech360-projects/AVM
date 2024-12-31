import 'dart:async';

import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/features/capture/models/filter_item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'memory_event.dart';
part 'memory_state.dart';

class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  MemoryBloc() : super(MemoryState.initial()) {
    on<DisplayedMemory>(_displayedMemory);
    on<DeletedMemory>(_deletedMemory);
    on<SearchMemory>(_searchMemory);
    on<UpdatedMemory>(_updatedMemory);
    on<MemoryIndexChanged>(_memoryChanged);
    on<FilterMemory>((event, emit) {
      switch (event.filterItem.filterType) {
        case 'Show All':
          // For 'Show All', we want to display all memories.
          emit(state.copyWith(
            status: MemoryStatus.success,
            memories: state.memories, // Keep all memories in the list
          ));
          break;

        case 'Technology':
          // Filter for 'Technology' category
          final filteredMemories = state.memories
              .where((e) => e.structured.target?.category == 'Technology')
              .toList();
          emit(state.copyWith(
            status: MemoryStatus.success,
            memories: filteredMemories,
          ));
          break;

        default:
          // Handle other cases or fallback logic here if necessary.
          emit(state.copyWith(
            status: MemoryStatus.success,
            memories: state
                .memories, // Optionally emit all memories or unchanged state
          ));
          break;
      }

      // Handle the toggle status of non-discarded items (outside switch)
      add(DisplayedMemory(isNonDiscarded: event.filterItem.filterStatus));
    });
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

  FutureOr<void> _deletedMemory(
      DeletedMemory event, Emitter<MemoryState> emit) async {
    try {
      emit(state.copyWith(
        status: MemoryStatus.loading,
      ));

      MemoryProvider().deleteMemory(event.memory);

      add(DisplayedMemory());
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
      final nonDiscardedMemories =
          allMemories.where((memory) => !memory.discarded).toList();
      final memoriesToConsider =
          event.isNonDiscarded ? nonDiscardedMemories : allMemories;
      memoriesToConsider.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      List<Memory> mostRecentMemory =
          memoriesToConsider.isNotEmpty ? memoriesToConsider : [];
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
      if (event.query.isEmpty) {
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
