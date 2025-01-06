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
    on<DisplayedMemory>(displayedMemory);
    on<DeletedMemory>(deletedMemory);
    on<SearchMemory>(searchMemory);
    on<UpdatedMemory>(updatedMemory);
    on<BatchDeleteMemory>(batchDeleteMemory);
    on<UpdatedSelection>(updatedSelection);
    on<MemoryIndexChanged>(memoryChanged);
    on<FilterMemory>(filterMemory);
  }

  // Method declarations
  FutureOr<void> filterMemory(FilterMemory event, Emitter<MemoryState> emit) {
    final allMemories = MemoryProvider().getMemories();
    List<Memory> filteredMemories = allMemories;

    if (event.filterItem.filterType == "Show All") {
      // Reset to all memories
      emit(state.copyWith(
        status: MemoryStatus.success,
        memories: allMemories, // Reset to all memories
      ));
    } else if (event.filterItem.filterType == "Today") {
      // Filter memories for today
      filteredMemories = allMemories.where((memory) {
        final createdAt = memory.createdAt;
        final today = DateTime.now();
        return createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).toList();
      filteredMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(
        status: MemoryStatus.success,
        memories: filteredMemories,
      ));
    } else if (event.filterItem.filterType == "This Week") {
      // Filter memories for this week
      final startOfWeek =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));

      filteredMemories = allMemories.where((memory) {
        final createdAt = memory.createdAt;
        return createdAt.isAfter(startOfWeek) &&
            createdAt.isBefore(endOfWeek);
      }).toList();
      filteredMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(
        status: MemoryStatus.success,
        memories: filteredMemories,
      ));
    } else if (event.filterItem.filterType == "DateRange") {
      // Filter memories between a date range
      final startDate = event.filterItem.startDate!;
      final endDate = event.filterItem.endDate!;

      filteredMemories = allMemories.where((memory) {
        final createdAt = memory.createdAt;
        return createdAt.isAfter(startDate) &&
            createdAt.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
      filteredMemories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(
        status: MemoryStatus.success,
        memories: filteredMemories,
      ));
    }
  }

  FutureOr<void> displayedMemory(DisplayedMemory event, Emitter<MemoryState> emit) async {
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

  FutureOr<void> deletedMemory(DeletedMemory event, Emitter<MemoryState> emit) async {
    try {
      emit(state.copyWith(status: MemoryStatus.loading));

      // Delete the memory from the provider or your data source
      MemoryProvider().deleteMemory(event.memory);

      // Remove the corresponding memory and its selection state
      final updatedMemories = List<Memory>.from(state.memories);
      final updatedSelectedMemories = List<bool>.from(state.selectedMemories);

      final memoryIndex = updatedMemories.indexOf(event.memory);
      if (memoryIndex != -1) {
        updatedMemories.removeAt(memoryIndex);
        updatedSelectedMemories.removeAt(memoryIndex);
      }

      // Update state with the new lists
      emit(state.copyWith(
        memories: updatedMemories,
        selectedMemories: updatedSelectedMemories,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: MemoryStatus.failure,
        failure: error.toString(),
      ));
    }
  }

  FutureOr<void> updatedMemory(UpdatedMemory event, Emitter<MemoryState> emit) async {
    MemoryProvider().updateMemoryStructured(event.structured);

    emit(state.copyWith(
      status: MemoryStatus.success,
    ));
  }

  FutureOr<void> updatedSelection(
      UpdatedSelection event, Emitter<MemoryState> emit) {
    if (event.selectedMemories.length == state.memories.length) {
      emit(state.copyWith(
          selectedMemories: event.selectedMemories,
          isCheckboxVisible:
              true)); // Make checkboxes visible when selection is updated
    } else {
      emit(state.copyWith(
          selectedMemories: List<bool>.filled(state.memories.length, false),
          isCheckboxVisible:
              false)); // Hide checkboxes when no selection is made
    }
  }

  FutureOr<void> batchDeleteMemory(
      BatchDeleteMemory event, Emitter<MemoryState> emit) async {
    try {
      emit(state.copyWith(status: MemoryStatus.loading));

      // Remove selected memories
      List<Memory> updatedMemories = List.from(state.memories);
      List<bool> selectedMemories = List.from(state.selectedMemories);

      // Loop through and delete selected memories
      for (int i = 0; i < selectedMemories.length; i++) {
        if (selectedMemories[i]) {
          Memory memory = updatedMemories[i];
          MemoryProvider().deleteMemory(memory); // Delete the memory
          updatedMemories.removeAt(i); // Remove from list
          selectedMemories.removeAt(i); // Remove selection state
          i--; // Adjust index after deletion
        }
      }

      emit(state.copyWith(
        memories: updatedMemories,
        selectedMemories: selectedMemories,
        isCheckboxVisible: false, // Hide checkboxes after deletion
      ));
    } catch (error) {
      emit(state.copyWith(
        status: MemoryStatus.failure,
        failure: error.toString(),
      ));
    }
  }

  FutureOr<void> searchMemory(SearchMemory event, Emitter<MemoryState> emit) {
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

  FutureOr<void> memoryChanged(MemoryIndexChanged event, Emitter<MemoryState> emit) async {
    final int newIndex = event.memoryIndex;
    emit(
      state.copyWith(memoryIndex: newIndex, status: MemoryStatus.success),
    );
  }
}
