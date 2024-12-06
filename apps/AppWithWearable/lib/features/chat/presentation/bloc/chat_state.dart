// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

// abstract class ChatState {}

// class ChatInitial extends ChatState {}

// class ChatLoading extends ChatState {}

// class ChatLoaded extends ChatState {
//   final List<Message> messages;
//   ChatLoaded(this.messages);
// }

// class ChatError extends ChatState {
//   final String error;
//   ChatError(this.error);
// }

enum ChatStatus { initial, loading, loaded, failure }

class ChatState extends Equatable {
  const ChatState({
    required this.status,
    this.messages = const [],
    this.errorMesage = '',
  });
  final ChatStatus status;
  final List<Message>? messages;
  final String errorMesage;

  @override
  List<Object?> get props => [status, messages, errorMesage];
  factory ChatState.initial() => const ChatState(status: ChatStatus.initial);
  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? errorMesage,
  }) {
    print("running >>>>>>>>>>>>>>>>>>>>>>>>>>>>????????????11111111>>>>>>");
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMesage: errorMesage ?? this.errorMesage,
    );
  }

  @override
  bool get stringify => true;
}
