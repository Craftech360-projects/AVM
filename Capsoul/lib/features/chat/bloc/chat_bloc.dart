import 'dart:async';
import 'dart:developer';

import 'package:capsoul/backend/api_requests/api/prompt.dart';
import 'package:capsoul/backend/api_requests/stream_api_response.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/memory_provider.dart';
import 'package:capsoul/backend/database/message.dart';
import 'package:capsoul/backend/database/message_provider.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/plugin.dart';
import 'package:capsoul/utils/rag.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    on<SendMessage>(_onSendMessage);
    on<RefreshMessages>(_refreshMessages);
    on<UpdateChat>((event, emit) async {
      final updatedMessages = MessageProvider().getMessages();
      emit(state.copyWith(messages: updatedMessages));
    });
  }

  /// Refresh messages and update the state
  Future<void> _refreshMessages(
      RefreshMessages event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // Re-fetch the updated messages
      List<Message> messages = messageProvider.getMessages();
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
      ));
    } catch (error) {
      log("Failed to refresh messages: $error");
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: "Failed to refresh messages.",
      ));
    }
  }

  /// Handle initial plugin message
  Future<void> _onSendInitialPluginMessage(
      SendInitialPluginMessage event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      var ai = Message(DateTime.now(), '', 'ai', pluginId: event.plugin?.id);
      await messageProvider.saveMessage(ai);

      await streamApiResponse(
        await getInitialPluginPrompt(event.plugin),
        _callbackFunctionChatStreaming(ai),
        () async {
          messageProvider.updateMessage(ai);
          add(LoadInitialChat());
        },
      );
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadedMessages(
      LoadInitialChat event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      List<Message> messages = messageProvider.getMessages();
      if (messages.isEmpty) {
        await sendInitialPluginMessage(null);
      } else {
        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
      ));
    }
  }

  /// Send a message and handle streaming response
  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      var aiMessage = _prepareStreaming(event.message);

      final ragInfo = await retrieveRAGContext(event.message);
      String ragContext = ragInfo[0];
      List<Memory> memories = ragInfo[1].cast<Memory>();

      var prompt = qaRagPrompt(
        ragContext,
        await messageProvider.retrieveMostRecentMessages(limit: 10),
      );

      await streamApiResponse(
        prompt,
        _callbackFunctionChatStreaming(aiMessage),
        () async {
          aiMessage.memories.addAll(memories);
          messageProvider.updateMessage(aiMessage);
          add(RefreshMessages());
          emit(state.copyWith(status: ChatStatus.loaded));
        },
      );
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
      ));
    }
  }

  /// Prepare messages for streaming
  Message _prepareStreaming(String text) {
    var human = Message(DateTime.now(), text, 'human');
    var ai = Message(DateTime.now(), '', 'ai');
    messageProvider.saveMessage(human);
    messageProvider.saveMessage(ai);
    return ai;
  }

  /// Handle streaming response for AI message
  Future<void> Function(String) _callbackFunctionChatStreaming(
      Message aiMessage) {
    return (String content) async {
      aiMessage.text = '${aiMessage.text}$content';
      await messageProvider.updateMessage(aiMessage);
    };
  }

  /// Handle sending initial plugin message (standalone function)
  Future<void> sendInitialPluginMessage(Plugin? plugin) async {
    try {
      var ai = Message(DateTime.now(), '', 'ai', pluginId: plugin?.id);
      messageProvider.saveMessage(ai);

      await streamApiResponse(
        await getInitialPluginPrompt(plugin),
        _callbackFunctionChatStreaming(ai),
        () async {
          messageProvider.updateMessage(ai);
          add(LoadInitialChat());
        },
      );
    } catch (error) {
      log(error.toString());
    }
  }
}
