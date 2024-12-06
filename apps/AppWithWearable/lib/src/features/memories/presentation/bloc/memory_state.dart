part of 'memory_bloc.dart';

abstract class MemoryState extends Equatable {
  const MemoryState();  

  @override
  List<Object> get props => [];
}
class MemoryInitial extends MemoryState {}
