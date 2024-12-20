// ignore_for_file: unused_field, unused_local_variable

import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avm/backend/database/message.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/chat/bloc/chat_bloc.dart';
import 'package:avm/features/chat/widgets/ai_message.dart';
import 'package:avm/features/chat/widgets/user_message.dart';

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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _chatBloc.add(LoadInitialChat());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  void _scrollToEnd() {
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
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        BlocBuilder<ChatBloc, ChatState>(
          bloc: _chatBloc,
          buildWhen: (previous, current) =>
              previous.messages?.length != current.messages?.length,
          builder: (context, state) {
            if (state.status == ChatStatus.loaded) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  _scrollToEnd();
                },
              );

              return Column(
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                    child: Row(
                      children: [
                        Text("Today",
                            style: TextStyle(
                                color: AppColors.purpleBright,
                                fontWeight: FontWeight.w500)),
                        w5,
                        Expanded(
                          child: Divider(
                            color: AppColors.purpleBright,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ListView for messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 130,
                        top: 20,
                      ),
                      itemCount: state.messages?.length ?? 0,
                      itemBuilder: (context, index) {
                        final message = state.messages?[index];

                        h10;

                        if (message?.senderEnum == MessageSender.ai) {
                          log(message.toString());
                          return Column(
                            children: [
                              AIMessage(
                                message: message!,
                                sendMessage: (msg) {
                                  // Handle send message
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
        //*-- Ask AVM --*//
      ],
    );
  }
}
