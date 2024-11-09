part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadInitialChat extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String message;

  SendMessage(this.message);
}

class RefreshMessages extends ChatEvent {}
// class PrepareStreaming extends ChatEvent {
//   final String text;
//   final String? pluginId;

//   PrepareStreaming(this.text, {this.pluginId});
// }

// class RetrieveRAGContext extends ChatEvent {
//   final String message;
//   final String? pluginId;

//   RetrieveRAGContext(this.message, {this.pluginId});
// }

// class CallbackFunctionChatStreaming extends ChatEvent {
//   final String content;

//   CallbackFunctionChatStreaming(this.content);
// }
class SendInitialPluginMessage extends ChatEvent {
  final Plugin? plugin;

  SendInitialPluginMessage(this.plugin);
}
