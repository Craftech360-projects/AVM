part of 'memory_bloc.dart';

enum MemoryStatus { initial, loading, success, failure }

class MemoryState extends Equatable {
  final MemoryStatus status;
  final List<Memory> memories;
  final List<Memory> filteredMemories;
  final String? failure;
  final int memoryIndex;

  const MemoryState({
    required this.status,
    this.memories = const [],
    this.filteredMemories = const [],
    this.failure,
    this.memoryIndex=0,
  });

  @override
  List<Object?> get props =>
      [status, memories, filteredMemories, memoryIndex, failure];

  factory MemoryState.initial() =>
      const MemoryState(status: MemoryStatus.initial);

  MemoryState copyWith({
    MemoryStatus? status,
    List<Memory>? memories,
    List<Memory>? originalMemories,
    int? memoryIndex,
    String? failure,
  }) {
    return MemoryState(
      status: status ?? this.status,
      memories: memories ?? this.memories,
      filteredMemories: originalMemories ?? filteredMemories,
      failure: failure ?? this.failure,
      memoryIndex: memoryIndex ?? this.memoryIndex,
    );
  }

  @override
  String toString() {
    final memoryDetails = memories.map((e) => e.toJson()).toList() ?? [];
    return 'MemoryState(status: $status, memories: $memoryDetails, failure: $failure)';
  }
}
