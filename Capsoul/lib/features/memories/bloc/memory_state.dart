part of 'memory_bloc.dart';

enum MemoryStatus { initial, loading, success, failure }

class MemoryState extends Equatable {
  final MemoryStatus status;
  final List<Memory> memories;
  final List<bool> selectedMemories;
  final List<Memory> filteredMemories;
  final String? failure;
  final int memoryIndex;
  final bool isCheckboxVisible; // Flag to track checkbox visibility

  const MemoryState({
    required this.status,
    required this.memories,
    required this.selectedMemories,
    this.filteredMemories = const [],
    this.failure,
    this.memoryIndex = 0,
    this.isCheckboxVisible = false, // Default to false
  });

  factory MemoryState.initial() => MemoryState(
        status: MemoryStatus.initial,
        memories: [],
        selectedMemories: [],
        isCheckboxVisible: false,
      );

  MemoryState copyWith({
    MemoryStatus? status,
    List<Memory>? memories,
    List<Memory>? filteredMemories,
    List<bool>? selectedMemories,
    int? memoryIndex,
    String? failure,
    bool? isCheckboxVisible,
  }) {
   final updatedSelectedMemories = selectedMemories ??
      (memories != null && memories.length != this.memories.length
          ? List<bool>.generate(memories.length, (_) => false)
          : this.selectedMemories);

    return MemoryState(
      status: status ?? this.status,
      memories: memories ?? this.memories,
      filteredMemories: filteredMemories ?? this.filteredMemories,
      selectedMemories: updatedSelectedMemories,
      failure: failure ?? this.failure,
      memoryIndex: memoryIndex ?? this.memoryIndex,
      isCheckboxVisible: isCheckboxVisible ?? this.isCheckboxVisible,
    );
  }

  @override
  List<Object?> get props => [
        status,
        memories,
        filteredMemories,
        selectedMemories,
        memoryIndex,
        failure,
        isCheckboxVisible,
      ];
}
