import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/api_requests/stream_api_response.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/utils/rag.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SharedPreferencesUtil prefs;
  final MessageProvider messageProvider;
  final MemoryProvider memoryProvider;

  ChatBloc(this.prefs, this.messageProvider, this.memoryProvider)
      : super(ChatInitial()) {
    on<LoadInitialChat>(_onLoadInitialChat);
    on<SendMessage>(_onSendMessage);
    on<RefreshMessages>(_onRefreshMessages);
  }

  void _onLoadInitialChat(
      LoadInitialChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      List<Message> messages = messageProvider.getMessages();
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      print(">>PLUGINCHECK");
      // Debug print to find out which plugin is being used

      print(
          "SharedPreferencesUtil().selectedChatPluginId: ${SharedPreferencesUtil().selectedChatPluginId}");
      // changeLoadingState();
      String? pluginId =
          SharedPreferencesUtil().selectedChatPluginId == 'no_selected'
              ? null
              : SharedPreferencesUtil().selectedChatPluginId;
      print('bloci>>>>>>> ${event.message}');
      var aiMessage =
          await _prepareStreaming(event.message, pluginId: pluginId);
      // print('bloci ai message ${aiMessage.}');
      dynamic ragInfo = await retrieveRAGContext(event.message,
          prevMessagesPluginId: pluginId);
      String ragContext = ragInfo[0];
      List<Memory> memories = ragInfo[1].cast<Memory>();
      print('RAG Context: $ragContext memories: ${memories.length}');
      var prompt = qaRagPrompt(
        ragContext,
        await messageProvider.retrieveMostRecentMessages(
            limit: 10, pluginId: pluginId),
      );
      print(
        "final prompt $pluginId, $prompt",
      );
      await streamApiResponse(
        prompt,
        _callbackFunctionChatStreaming(aiMessage),
        () {
          aiMessage.memories.addAll(memories);
          messageProvider.updateMessage(aiMessage);
          add(RefreshMessages());
        },
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onRefreshMessages(RefreshMessages event, Emitter<ChatState> emit) {
    List<Message> messages = messageProvider.getMessages();
    emit(ChatLoaded(messages));
  }
}

_prepareStreaming(String text, {String? pluginId}) {
  // textController.clear(); // setState if isolated
  var human = Message(DateTime.now(), text, 'human');
  var ai = Message(DateTime.now(), '', 'ai', pluginId: pluginId);
  MessageProvider().saveMessage(human);
  MessageProvider().saveMessage(ai);
  // widget.messages.add(human);
  // widget.messages.add(ai);
  // _moveListToBottom(extra: widget.textFieldFocusNode.hasFocus ? 148 : 200);
  return ai;
}

_callbackFunctionChatStreaming(Message aiMessage) {
  return (String content) async {
    aiMessage.text = '${aiMessage.text}$content';
    MessageProvider().updateMessage(aiMessage);
    // widget.messages.removeLast();
    // widget.messages.add(aiMessage);
    // setState(() {});
    // _moveListToBottom();
  };
}
