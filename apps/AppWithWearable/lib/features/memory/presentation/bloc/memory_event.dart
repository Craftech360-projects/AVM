// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'memory_bloc.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object> get props => [];
}

class DisplayedMemory extends MemoryEvent {
  final bool isNonDiscarded;
  const DisplayedMemory({this.isNonDiscarded = true});
  @override
  List<Object> get props => [isNonDiscarded];
}

class SearchMemory extends MemoryEvent {
  final String query;

  const SearchMemory({required this.query});
  @override
  List<Object> get props => [query];
}

class DeletedMemory extends MemoryEvent {
  final Memory memory;
  const DeletedMemory({required this.memory});
  @override
  List<Object> get props => [memory];
}

class UpdatedMemory extends MemoryEvent {
  final Structured structured;
  const UpdatedMemory({required this.structured});
  @override
  List<Object> get props => [structured];
}

class MemoryIndexChanged extends MemoryEvent {
  final int memoryIndex;
  const MemoryIndexChanged({required this.memoryIndex});
  @override
  List<Object> get props => [memoryIndex];
}

class FilterMemory extends MemoryEvent {
  final FilterItem filterItem;
  const FilterMemory({
    required this.filterItem,
  });
  @override
  List<Object> get props => [filterItem];
}
