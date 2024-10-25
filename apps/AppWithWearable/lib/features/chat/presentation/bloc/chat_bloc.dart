import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  Timer? _dailySummaryTimer; // Declare a Timer for daily summary

  ChatBloc(this.prefs, this.messageProvider, this.memoryProvider)
      : super(ChatState.initial()) {
    on<LoadInitialChat>(_onLoadedMessages);
    on<SendInitialPluginMessage>(_onSendInitialPluginMessage);
    on<SendMessage>(_onSendMessage);
    on<InitializeDailySummary>(
        _onInitializeDailySummary); // New event registration
  }

  _callbackFunctionChatStreaming(Message aiMessage) {
    return (String content) async {
      aiMessage.text = '${aiMessage.text}$content';
      await messageProvider.updateMessage(aiMessage); // Ensure this is awaited
    };
  }

  // Future<void> _onInitializeDailySummary(
  //     InitializeDailySummary event, Emitter<ChatState> emit) async {
  //   _dailySummaryTimer =
  //       Timer.periodic(const Duration(hours: 1), (timer) async {
  //     var now = DateTime.now();
  //     if (now.hour < 20) return; // Only run after 8 PM

  //     if (prefs.lastDailySummaryDay != '') {
  //       var secondsFrom8pm = now
  //           .difference(DateTime(now.year, now.month, now.day, 20))
  //           .inSeconds;
  //       var lastRunTime = DateTime.parse(prefs.lastDailySummaryDay);
  //       var secondsFromLast = now.difference(lastRunTime).inSeconds;
  //       if (secondsFromLast < secondsFrom8pm) {
  //         timer.cancel();
  //         return;
  //       }
  //     }

  //     timer.cancel(); // Stop the timer after running the summary
  //     var memories = memoryProvider.retrieveDayMemories(now);
  //     if (memories.isEmpty) {
  //       prefs.lastDailySummaryDay = DateTime.now().toIso8601String();
  //       return;
  //     }

  //     var message = Message(DateTime.now(), '', 'ai', type: 'daySummary');
  //     messageProvider.saveMessage(message);

  //     // Here you would send the summary notification
  //     var result = await dailySummaryNotifications(memories);
  //     prefs.lastDailySummaryDay = DateTime.now().toIso8601String();
  //     message.text = result;
  //     message.memories.addAll(memories);
  //     messageProvider.updateMessage(message);

  //     add(LoadInitialChat()); // Reload chat to display the summary
  //   });
  // }

  Future<void> _onInitializeDailySummary(
      InitializeDailySummary event, Emitter<ChatState> emit) async {
    _dailySummaryTimer =
        Timer.periodic(const Duration(hours: 1), (timer) async {
      // Changed to run every minute
      var now = DateTime.now();
      log(timer.tick.toString());
      log("daily timer runnig>>>>>>>>>>>>>>");
      if (now.hour < 20) return; // Only run after 8 PM

      if (prefs.lastDailySummaryDay != '') {
        var secondsFrom8pm = now
            .difference(DateTime(now.year, now.month, now.day, 20))
            .inSeconds;
        var lastRunTime = DateTime.parse(prefs.lastDailySummaryDay);
        var secondsFromLast = now.difference(lastRunTime).inSeconds;
        if (secondsFromLast < secondsFrom8pm) {
          timer.cancel();
          return;
        }
      }

      timer.cancel(); // Stop the timer after running the summary
      var memories = memoryProvider.retrieveDayMemories(now);
      if (memories.isEmpty) {
        prefs.lastDailySummaryDay = DateTime.now().toIso8601String();
        return;
      }

      var message = Message(DateTime.now(), '', 'ai', type: 'daySummary');
      messageProvider.saveMessage(message);

      // Here you would send the summary notification
      var result = await dailySummaryNotifications(memories);
      prefs.lastDailySummaryDay = DateTime.now().toIso8601String();
      message.text = result;
      message.memories.addAll(memories);
      messageProvider.updateMessage(message);

      add(LoadInitialChat()); // Reload chat to display the summary
    });
  }

  //test function for 1 minute daily memory

  // Future<void> _onInitializeDailySummary(
  //     InitializeDailySummary event, Emitter<ChatState> emit) async {
  //   print('InitializeDailySummary');
  //   _dailySummaryTimer =
  //       Timer.periodic(const Duration(minutes: 1), (timer) async {
  //     // Now runs every minute regardless of previous executions
  //     var now = DateTime.now();

  //     if (now.hour < 20) return; // Only run after 8 PM

  //     // No check for previous summary; we want to create one every time
  //     var memories = memoryProvider.retrieveDayMemories(now);

  //     // Create a message object
  //     var message = Message(DateTime.now(), '', 'ai', type: 'daySummary');
  //     messageProvider.saveMessage(message);

  //     // Send the summary notification
  //     var result = await dailySummaryNotifications(memories);

  //     // Update the message with the new details
  //     message.text = result;
  //     message.memories.addAll(memories);
  //     messageProvider.updateMessage(message);

  //     // Update the last summary day regardless of previous runs
  //     prefs.lastDailySummaryDay = DateTime.now().toIso8601String();

  //     add(LoadInitialChat()); // Reload chat to display the summary
  //   });
  // }

  Future<void> sendInitialPluginMessage(Plugin? plugin) async {
    var ai = Message(DateTime.now(), '', 'ai', pluginId: plugin?.id);
    await messageProvider.saveMessage(ai);

    // Stream the initial plugin prompt
    await streamApiResponse(
      await getInitialPluginPrompt(plugin),
      _callbackFunctionChatStreaming(
          ai), // Ensure this function returns a Future
      () {
        messageProvider.updateMessage(ai);
        add(LoadInitialChat()); // Refresh messages
      },
    );
  }

  Future<void> _onLoadedMessages(
      LoadInitialChat event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      List<Message> messages = messageProvider.getMessages();
      emit(state.copyWith(status: ChatStatus.loaded, messages: messages));

      int messageCount = messageProvider.getMessagesCount();
      if (messageCount == 0) {
        sendInitialPluginMessage(
            null); // Optionally send initial message if no messages exist
      }
    } catch (error) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMesage: error.toString()));
    }
  }

  Future<void> _onSendInitialPluginMessage(
      SendInitialPluginMessage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      var ai = Message(DateTime.now(), '', 'ai', pluginId: event.plugin?.id);
      await messageProvider.saveMessage(ai);

      List<Message> messages = messageProvider.getMessages();
      emit(state.copyWith(status: ChatStatus.loaded, messages: messages));

      await streamApiResponse(
        await getInitialPluginPrompt(event.plugin),
        _callbackFunctionChatStreaming(ai),
        () {
          messageProvider.updateMessage(ai);
          add(RefreshMessages());
        },
      );

      emit(state.copyWith(status: ChatStatus.loaded));
    } catch (error) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMesage: error.toString()));
    }
  }

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
        () {
          aiMessage.memories.addAll(memories);
          messageProvider.updateMessage(aiMessage);
          add(LoadInitialChat());
        },
      );
    } catch (error) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMesage: error.toString()));
    }
  }

  Message _prepareStreaming(String text) {
    var human = Message(DateTime.now(), text, 'human');
    var ai = Message(DateTime.now(), '', 'ai');
    messageProvider.saveMessage(human);
    messageProvider.saveMessage(ai);
    return ai;
  }

  @override
  Future<void> close() {
    _dailySummaryTimer?.cancel(); // Cancel the timer when the bloc is closed
    return super.close();
  }
}
