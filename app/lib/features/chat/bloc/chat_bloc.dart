import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<SendMessage>(_onSendMessage);
    on<RefreshMessages>(_refreshMessages);
  }

  /// Refresh messages and update the state
  Future<void> _refreshMessages(
      RefreshMessages event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      // Fetch updated messages
      List<Message> messages = messageProvider.getMessages();
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
      ));
      print("Messages refreshed. Count: ${messages.length}");
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
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

      print("AI message created with plugin ID: ${event.plugin?.id}");

      await streamApiResponse(
        await getInitialPluginPrompt(event.plugin),
        _callbackFunctionChatStreaming(ai),
        () async {
          messageProvider.updateMessage(ai);
          add(LoadInitialChat()); // Reload the chat after streaming
        },
      );
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
      ));
    }
  }

  /// Load initial messages when the screen is loaded
  Future<void> _onLoadedMessages(
      LoadInitialChat event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      List<Message> messages = messageProvider.getMessages();
      if (messages.isEmpty) {
        print("No messages found. Sending initial plugin message.");
        await sendInitialPluginMessage(null);
      } else {
        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
        ));
        print("Loaded initial messages. Count: ${messages.length}");
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

      // Retrieve the RAG context
      final ragInfo = await retrieveRAGContext(event.message);
      String ragContext = ragInfo[0];
      List<Memory> memories = ragInfo[1].cast<Memory>();

      print("RAG Context: $ragContext | Memories: ${memories.length}");

      // Create a prompt using the RAG context
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
          add(RefreshMessages()); // Refresh after the stream
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
      await messageProvider
          .updateMessage(aiMessage); // Ensure update is awaited
      print("AI Message updated: ${aiMessage.text}");
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
      print("Error in sendInitialPluginMessage: $error");
    }
  }
}
