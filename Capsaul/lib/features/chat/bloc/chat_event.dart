part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadInitialChat extends ChatEvent {}

// class SendMessage extends ChatEvent {
//   final String message;
//   SendMessage(this.message);
// }

class SendMessage extends ChatEvent {
  final String message;
  final String? memoryContext; // Add this
  SendMessage(this.message, {this.memoryContext}); // Update constructor
}


class RefreshMessages extends ChatEvent {}
class SendInitialPluginMessage extends ChatEvent {
  final Plugin? plugin;

  SendInitialPluginMessage(this.plugin);
}
  class UpdateChat extends ChatEvent {}