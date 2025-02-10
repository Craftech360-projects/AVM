import 'dart:async';

import 'package:altio/backend/api_requests/api/prompt.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/database/message.dart';
import 'package:altio/backend/database/message_provider.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/chat/bloc/chat_bloc.dart';
import 'package:altio/features/chat/widgets/ai_message.dart';
import 'package:altio/features/chat/widgets/user_message.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final FocusNode textFieldFocusNode;
  final String? initialQuestion;
  final Structured? memoryContext;

  const ChatScreen(
      {super.key,
      required this.textFieldFocusNode,
      this.initialQuestion,
      this.memoryContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late ChatBloc _chatBloc;
  late AnimationController _animationController;
  late Timer _dailySummaryTimer;
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _messageKeys = {};

  _initDailySummary() {
    var now = DateTime.now();
    _dailySummaryTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (now.hour < 20) return;

      if (SharedPreferencesUtil().lastDailySummaryDay != '') {
        var secondsFrom8pm = now
            .difference(DateTime(now.year, now.month, now.day, 20))
            .inSeconds;
        var at = DateTime.parse(SharedPreferencesUtil().lastDailySummaryDay);
        var secondsFromLast = now.difference(at).inSeconds;
        if (secondsFromLast < secondsFrom8pm) {
          timer.cancel();
          return;
        }
      }

      timer.cancel();

      var memories = MemoryProvider().retrieveDayMemories(now);

      if (memories.isEmpty) {
        SharedPreferencesUtil().lastDailySummaryDay =
            DateTime.now().toIso8601String();
        return;
      }

      var message = Message(DateTime.now(), '', 'ai', type: 'daySummary');

      MessageProvider().saveMessage(message);

      var result = await dailySummaryNotifications(memories);

      SharedPreferencesUtil().lastDailySummaryDay =
          DateTime.now().toIso8601String();

      message.text = result;
      message.memories.addAll(memories);
      MessageProvider().updateMessage(message);
      _chatBloc.add(RefreshMessages());
    });
  }

  @override
  void initState() {
    super.initState();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _scrollController = ScrollController();
    if (widget.initialQuestion != null && widget.memoryContext != null) {
      final memoryTitle = widget.memoryContext?.title ?? "Unknown Context";
      final message =
          "Context: $memoryTitle\nQuestion: ${widget.initialQuestion}";
      _chatBloc.add(SendMessage(message));
    } else {
      _chatBloc.add(LoadInitialChat());
    }

    _initDailySummary();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _dailySummaryTimer.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      buildWhen: (previous, current) =>
          previous.messages != current.messages ||
          previous.status != current.status,
      builder: (context, state) {
        if (state.status == ChatStatus.loading) {
          return Center(
            child: TypingIndicator(),
          );
        }

        Message? pinnedMessage;
        try {
          pinnedMessage =
              state.messages?.firstWhereOrNull((msg) => msg.isPinned);
        } catch (e) {
          pinnedMessage = null;
        }

        // Message? pinnedMessage;
        //     try {
        //       pinnedMessage = state.messages?.firstWhere((msg) => msg.isPinned);
        //     } catch (e) {
        //       pinnedMessage = null;
        //     }

        return Stack(children: [
          ListView.builder(
            controller: _scrollController,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 80,
              top: pinnedMessage != null ? 80 : 20,
            ),
            itemCount: state.messages?.length ?? 0,
            itemBuilder: (context, index) {
              final message =
                  state.messages?[state.messages!.length - 1 - index];
              bool isAIMessage = message?.senderEnum == MessageSender.ai;

              _messageKeys[message!.id] ??= GlobalKey();

              final key = _messageKeys[message.id];

              if (isAIMessage) {
                return Column(
                  key: key,
                  children: [
                    AIMessage(
                      message: message,
                      sendMessage: (msg) {},
                      displayOptions: state.messages!.length <= 1,
                      memories: message.memories,
                      pluginSender: SharedPreferencesUtil()
                          .pluginsList
                          .firstWhereOrNull((e) => e.id == message.pluginId),
                    ),
                    h8,
                  ],
                );
              } else {
                return Column(
                  key: key,
                  children: [
                    UserMessage(message: message),
                    h8,
                  ],
                );
              }
            },
          ),
          if (pinnedMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: AppColors.purpleDark,
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.white, borderRadius: br5),
                      child: InkWell(
                        enableFeedback: true,
                        onTap: () {
                          context.read<ChatBloc>().add(UnpinMessage());
                          avmSnackBar(context, "Message unpinned");
                        },
                        child: Icon(
                          Icons.push_pin_outlined,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    w8,
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final messageKey = _messageKeys[pinnedMessage?.id];
                          if (messageKey != null &&
                              messageKey.currentContext != null) {
                            final box = messageKey.currentContext!
                                .findRenderObject() as RenderBox;
                            final position = box.localToGlobal(Offset.zero).dy;

                            _scrollController.animateTo(
                              _scrollController.offset + position - 80,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: Tooltip(
                          message: pinnedMessage.text,
                          child: Text(
                            pinnedMessage.text.length > 100
                                ? '${pinnedMessage.text.substring(0, 100)}...'
                                : pinnedMessage.text,
                            style:
                                TextStyle(color: AppColors.white, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ]);
      },
    );
  }
}
