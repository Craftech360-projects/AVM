part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, loaded, failure, userMessageSent }

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
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMesage: errorMesage ?? this.errorMesage,
    );
  }

  @override
  bool get stringify => true;
}
