// ignore_for_file: public_member_api_docs, sort_constructors_first
// part of 'chat_bloc.dart';

// enum ChatStatus { initial, loading, loaded, failure }

// class ChatState extends Equatable {
//   const ChatState({
//     required this.status,
//     this.messages = const [],
//     this.errorMesage = '',
//   });
//   final ChatStatus status;
//   final List<Message>? messages;
//   final String errorMesage;

//   @override
//   List<Object?> get props => [status, messages, errorMesage];
//   factory ChatState.initial() => const ChatState(status: ChatStatus.initial);
//   ChatState copyWith({
//     ChatStatus? status,
//     List<Message>? messages,
//     String? errorMesage,
//   }) {
//     print("running >>>>>>>>>>>>>>>>>>>>>>>>>>>>????????????11111111>>>>>>");
//     return ChatState(
//       status: status ?? this.status,
//       messages: messages ?? this.messages,
//       errorMesage: errorMesage ?? this.errorMesage,
//     );
//   }

//   @override
//   bool get stringify => true;
// }

part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, failure }

class ChatState extends Equatable {
  const ChatState({
    required this.status,
    this.messages = const [],
    this.errorMesage = '',
  });

  final ChatStatus status; // Current status of the chat
  final List<Message>? messages; // List of messages in the chat
  final String errorMesage; // Error message if any

  @override
  List<Object?> get props =>
      [status, messages, errorMesage]; // List of props for equality checks

  // Factory constructor for initial state
  factory ChatState.initial() => const ChatState(status: ChatStatus.initial);

  // Method to create a copy of the current state with updated values
  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? errorMesage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMesage: errorMesage ?? this.errorMesage,
    );
  }

  @override
  bool get stringify => true; // Enables string representation of the state
}
