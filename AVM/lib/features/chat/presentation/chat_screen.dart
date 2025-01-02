// ignore_for_file: unused_field, unused_local_variable

import 'dart:async';

import 'package:avm/backend/api_requests/api/prompt.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/database/message.dart';
import 'package:avm/backend/database/message_provider.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/core/widgets/typing_indicator.dart';
import 'package:avm/features/chat/bloc/chat_bloc.dart';
import 'package:avm/features/chat/widgets/ai_message.dart';
import 'package:avm/features/chat/widgets/user_message.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  late AnimationController _animationController;
  bool _isScrolled = false;
  // ignore: unused_field
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  void _scrollToEnd({bool force = false}) {
    if (!_scrollController.hasClients) return;

    // Check if user is already near the bottom
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (force || (maxScroll - currentScroll <= 100)) {
      // Only auto-scroll if forcing or user is near the bottom
      _scrollController.animateTo(
        maxScroll,
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
    return Stack(
      children: [
        BlocBuilder<ChatBloc, ChatState>(
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

            if (state.status == ChatStatus.loaded) {
              // Avoid forcing scroll when rendering messages
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 80,
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
                                sendMessage: (msg) {
                                  // Handle AI response logic.
                                },
                                displayOptions: state.messages!.length <= 1,
                                memories: message.memories,
                                pluginSender: SharedPreferencesUtil()
                                    .pluginsList
                                    .firstWhereOrNull(
                                        (e) => e.id == message.pluginId),
                              ),
                              h10,
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              UserCard(
                                message: message,
                              ),
                              h10,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // _chatBloc.state.status == ChatStatus.loading ==> Use this for loader
        if (_isScrolled)
          Positioned(top: 0, left: 0, right: 0, child: _buildScrollGradient()),
      ],
    );
  }

  Widget _buildScrollGradient() {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.commonPink.withValues(alpha: 0.025)
          ],
        ),
      ),
    );
  }
}
