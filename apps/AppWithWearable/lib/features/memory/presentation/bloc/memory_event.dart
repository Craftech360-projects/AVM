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

