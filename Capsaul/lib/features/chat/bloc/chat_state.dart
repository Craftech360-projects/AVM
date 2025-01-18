part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  failure,
  userMessageSent,
  waitingForAI
}

class ChatState extends Equatable {
  const ChatState({
    required this.status,
    this.messages = const [],
    this.errorMesage = '',
    this.isUserMessageSent = false, 
  });
  final ChatStatus status;
  final List<Message>? messages;
  final String errorMesage;
  final bool isUserMessageSent;

  @override
  List<Object?> get props => [status, messages, errorMesage, isUserMessageSent];
  factory ChatState.initial() => const ChatState(status: ChatStatus.initial);
  ChatState copyWith({
    ChatStatus? status,
    List<Message>? messages,
    String? errorMesage,
     bool? isUserMessageSent, 
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMesage: errorMesage ?? this.errorMesage,
      isUserMessageSent: isUserMessageSent ?? this.isUserMessageSent,
    );
  }

  @override
  bool get stringify => true;
}
