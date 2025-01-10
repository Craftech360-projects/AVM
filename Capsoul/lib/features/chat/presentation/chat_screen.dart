// ignore_for_file: unused_field

import 'dart:async';

import 'package:capsoul/backend/api_requests/api/prompt.dart';
import 'package:capsoul/backend/database/memory_provider.dart';
import 'package:capsoul/backend/database/message.dart';
import 'package:capsoul/backend/database/message_provider.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/widgets/typing_indicator.dart';
import 'package:capsoul/features/chat/bloc/chat_bloc.dart';
import 'package:capsoul/features/chat/widgets/ai_message.dart';
import 'package:capsoul/features/chat/widgets/user_message.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  final FocusNode textFieldFocusNode;

  const ChatScreen({
    super.key,
    required this.textFieldFocusNode,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _aiChatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  late AnimationController _animationController;
  final bool _isScrolled = false;
  late Animation<double> _animation;
  late Timer _dailySummaryTimer;

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
    _chatBloc.add(LoadInitialChat());

    _initDailySummary();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _dailySummaryTimer.cancel();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state.status == ChatStatus.loaded ||
            state.status == ChatStatus.userMessageSent) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        bloc: _chatBloc,
        buildWhen: (previous, current) =>
            previous.messages != current.messages ||
            previous.status != current.status,
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return Center(child: TypingIndicator());
          }

          if (state.status == ChatStatus.loaded) {
            return ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 90,
                top: 20,
              ),
              itemCount: state.messages?.length ?? 0,
              itemBuilder: (context, index) {
                final message = state.messages?[index];
                if (message?.senderEnum == MessageSender.ai) {
                  return Column(
                    children: [
                      AIMessage(
                        message: message!,
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
                    children: [
                      UserCard(message: message),
                      h8,
                    ],
                  );
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
