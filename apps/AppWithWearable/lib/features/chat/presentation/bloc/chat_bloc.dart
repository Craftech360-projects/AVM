import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/api_requests/api/prompt.dart';
import 'package:friend_private/backend/api_requests/stream_api_response.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/database/message_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/utils/rag.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SharedPreferencesUtil prefs;
  final MessageProvider messageProvider;
  final MemoryProvider memoryProvider;

  ChatBloc(this.prefs, this.messageProvider, this.memoryProvider)
      : super(ChatState.initial()) {
    on<LoadInitialChat>(_onLoadedMessages);
    on<SendInitialPluginMessage>(_onSendInitialPluginMessage);

    on<SendMessage>(
      (event, emit) async {
        try {
          print('event bloc ${event.message}');
          emit(state.copyWith(status: ChatStatus.loading));
          // Prepare and save the initial messages
          var aiMessage = _prepareStreaming(event.message);

          // Retrieve the RAG context
          final ragInfo = await retrieveRAGContext(event.message);
          print('raginfo $ragInfo');
          //after rag ne to update ui, to show user message
          String ragContext = ragInfo[0];
          List<Memory> memories = ragInfo[1].cast<Memory>();
          print('RAG Context: $ragContext memories: ${memories.length}');
//
          // Use the RAG context to create a prompt
          var prompt = qaRagPrompt(
            ragContext,
            await MessageProvider().retrieveMostRecentMessages(limit: 10),
          );
          //  MessageProvider().updateMessage(aiMessage);
          add(LoadInitialChat());

          // Stream the AI response and update the AI message
          await streamApiResponse(
            prompt,
            _callbackFunctionChatStreaming(aiMessage),
            () {
              aiMessage.memories.addAll(memories);
              MessageProvider().updateMessage(aiMessage);
              add(LoadInitialChat());
            },
          );
        } catch (error) {
          emit(
            state.copyWith(
                status: ChatStatus.failure, errorMesage: error.toString()),
          );
        }
      },
    );

    // on<SendMessage>(_onSendMessage);
    // on<RefreshMessages>(_onRefreshMessages);
  }
  Future<void> _onSendInitialPluginMessage(
      SendInitialPluginMessage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      print("hereeee");
      var ai = Message(DateTime.now(), '', 'ai', pluginId: event.plugin?.id);
      await messageProvider.saveMessage(ai);

      // Update state to include the new message and refresh the view
      List<Message> messages = messageProvider.getMessages();
      emit(state.copyWith(status: ChatStatus.loaded, messages: messages));

      // Process the response from API
      await streamApiResponse(
        await getInitialPluginPrompt(event.plugin),
        _callbackFunctionChatStreaming(ai),
        () {
          messageProvider.updateMessage(ai);
          add(RefreshMessages());
        },
      );

      // Optionally, you can handle loading state or other UI updates here
      emit(state.copyWith(status: ChatStatus.loaded));
    } catch (error) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMesage: error.toString()));
    }
  }

  FutureOr<void> _onLoadedMessages(event, emit) {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      List<Message> messages = messageProvider.getMessages();
      for (var element in messages) {
        debugPrint('chat message bloc ${element.memories}');
      }
      // print('message length ${messages}');
      emit(state.copyWith(status: ChatStatus.loaded, messages: messages));
      // Optionally, you can also get the count of messages
      int messageCount = messageProvider.getMessagesCount();
      print('Total number of messages: $messageCount');
      if (messageCount == 0) {
        sendInitialPluginMessage(null);
      } else {
        print(messages.toString());
      }
    } catch (error) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMesage: error.toString()));
    }
  }
}

sendInitialPluginMessage(Plugin? plugin) async {
  var ai = Message(DateTime.now(), '', 'ai', pluginId: plugin?.id);
  MessageProvider().saveMessage(ai);
  // widget.messages.add(ai);
  // _moveListToBottom();
  streamApiResponse(
    await getInitialPluginPrompt(plugin),
    _callbackFunctionChatStreaming(ai),
    () {
      // MessageProvider().updateMessage(ai);
      // widget.refreshMessages();
    },
  );
  // changeLoadingState();
}

/*
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
      print('bloci ${event.message}');
      var aiMessage = await _prepareStreaming(event.message);
     
      dynamic ragInfo = await retrieveRAGContext(event.message);
      String ragContext = ragInfo[0];
      List<Memory> memories = ragInfo[1].cast<Memory>();
      print('RAG Context: $ragContext memories: ${memories.length}');
      var prompt = qaRagPrompt(
        ragContext,
        await messageProvider.retrieveMostRecentMessages(limit: 10),
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
*/
_prepareStreaming(String text) {
  // textController.clear(); // setState if isolated
  var human = Message(DateTime.now(), text, 'human');
  var ai = Message(
    DateTime.now(),
    '',
    'ai',
  );
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
