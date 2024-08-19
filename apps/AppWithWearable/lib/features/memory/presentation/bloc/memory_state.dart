part of 'memory_bloc.dart';

enum MemoryStatus { initial, loading, success, failure }

class MemoryState extends Equatable {
  final MemoryStatus status;
  final List<Memory>? memories;
  final List<Memory>? filteredMemories;
  final String? failure;

  const MemoryState({
    required this.status,
    this.memories,
    this.filteredMemories,
    this.failure,
  });

  @override
  List<Object?> get props => [status, memories, filteredMemories, failure];

  factory MemoryState.initial() =>
      const MemoryState(status: MemoryStatus.initial);

  MemoryState copyWith({
    MemoryStatus? status,
    List<Memory>? memories,
    List<Memory>? originalMemories,
    String? failure,
  }) {
    return MemoryState(
      status: status ?? this.status,
      memories: memories ?? this.memories,
      filteredMemories: originalMemories ?? this.filteredMemories,
      failure: failure ?? this.failure,
    );
  }

  @override
  String toString() {
    final memoryDetails = memories?.map((e) => e.toJson()).toList() ?? [];
    return 'MemoryState(status: $status, memories: $memoryDetails, failure: $failure)';
  }
}
