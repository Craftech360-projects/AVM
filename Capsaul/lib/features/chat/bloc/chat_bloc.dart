import 'dart:async';
import 'dart:developer';

import 'package:capsaul/backend/api_requests/api/prompt.dart';
import 'package:capsaul/backend/api_requests/stream_api_response.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/database/message.dart';
import 'package:capsaul/backend/database/message_provider.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/utils/rag.dart';
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

    on<DeleteMessage>((event, emit) async {
      try {
        bool success = await messageProvider.deleteMessage(event.message);

        if (success) {
          List<Message> updatedMessages = messageProvider.getMessages();
          emit(state.copyWith(messages: updatedMessages));
        } else {
          emit(state.copyWith(status: ChatStatus.failure));
          log('Failed to delete the message.');
        }
      } catch (error) {
        log('Error deleting message: $error');
        emit(state.copyWith(
          status: ChatStatus.failure,
          errorMesage: 'An unexpected error occurred.',
        ));
      }
    });

    on<DeleteAllMessages>((event, emit) async {
      try {
        bool success =
            await messageProvider.deleteMessages(state.messages ?? []);
        if (success) {
          emit(state.copyWith(messages: []));
        }
      } catch (e) {
        log('Failed to clear chat: $e');
        emit(state.copyWith(status: ChatStatus.failure));
      }
    });

    on<PinMessage>((event, emit) async {
      try {
        List<Message> pinnedMessages = await messageProvider.getPinnedMessages();
for (var msg in pinnedMessages) {
  msg.isPinned = false;
  await messageProvider.updateMessage(msg);
}


        event.message.isPinned = true;
        await messageProvider.updateMessage(event.message);

        emit(state.copyWith(messages: messageProvider.getMessages()));
      } catch (e) {
        log("Failed to pin message: $e");
        emit(state.copyWith(status: ChatStatus.failure));
      }
    });

    on<UnpinMessage>((event, emit) async {
      try {
        List<Message> messages = state.messages ?? [];
        for (var msg in messages) {
          if (msg.isPinned) {
            msg.isPinned = false;
            await messageProvider.updateMessage(msg);
          }
        }

        emit(state.copyWith(messages: messageProvider.getMessages()));
      } catch (e) {
        log("Failed to unpin message: $e");
        emit(state.copyWith(status: ChatStatus.failure));
      }
    });
  }

  Future<void> _refreshMessages(
      RefreshMessages event, Emitter<ChatState> emit) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

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

  Future<void> _onSendMessage(
      SendMessage event, Emitter<ChatState> emit) async {
    try {
      var userMessage = Message(DateTime.now(), event.message, 'human');
      messageProvider.saveMessage(userMessage);

      emit(state.copyWith(
        status: ChatStatus.userMessageSent,
        messages: [...?state.messages, userMessage],
        isUserMessageSent: true,
      ));

      emit(state.copyWith(status: ChatStatus.waitingForAI));

      // Include memory context if available
      String memoryContext = event.memoryContext ?? "";
      String prompt =
          "${memoryContext.isNotEmpty ? "Memory Context:\n$memoryContext\n\n" : ""}${event.message}";

      var aiMessage = _prepareStreaming(event.message);

      final ragInfo = await retrieveRAGContext(prompt);
      String ragContext = ragInfo[0];
      List<Memory> memories = ragInfo[1].cast<Memory>();

      var finalPrompt = qaRagPrompt(
        ragContext,
        await messageProvider.retrieveMostRecentMessages(limit: 10),
      );

      await streamApiResponse(
        finalPrompt,
        _callbackFunctionChatStreaming(aiMessage),
        () async {
          aiMessage.memories.addAll(memories);
          await messageProvider.updateMessage(aiMessage);

          add(RefreshMessages());
          emit(state.copyWith(
            status: ChatStatus.loaded,
            isUserMessageSent: false,
          ));
        },
      );
    } catch (error) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMesage: error.toString(),
      ));
    }
  }

  Message _prepareStreaming(String text) {
    var ai = Message(DateTime.now(), '', 'ai');
    messageProvider.saveMessage(ai);
    return ai;
  }

  Future<void> Function(String) _callbackFunctionChatStreaming(
      Message aiMessage) {
    return (String content) async {
      aiMessage.text = '${aiMessage.text}$content';
      await messageProvider.updateMessage(aiMessage);
    };
  }

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
