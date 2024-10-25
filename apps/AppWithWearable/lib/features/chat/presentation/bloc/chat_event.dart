// part of 'chat_bloc.dart';

// abstract class ChatEvent {}

// class LoadInitialChat extends ChatEvent {}

// class SendMessage extends ChatEvent {
//   final String message;
//   SendMessage(this.message);
// }

// class RefreshMessages extends ChatEvent {}

// class SendInitialPluginMessage extends ChatEvent {
//   final Plugin? plugin;

//   SendInitialPluginMessage(this.plugin);
// }

part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInitialChat extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage(this.message);

  @override
  List<Object?> get props => [message]; // Include message for equality checks
}

class RefreshMessages extends ChatEvent {}

class SendInitialPluginMessage extends ChatEvent {
  final Plugin? plugin;

  SendInitialPluginMessage(this.plugin);

  @override
  List<Object?> get props => [plugin]; // Include plugin for equality checks
}

class InitializeDailySummary extends ChatEvent {} // Add daily summary event
