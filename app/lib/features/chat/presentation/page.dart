import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/features/chat/bloc/chat_bloc.dart';
import 'package:friend_private/features/chat/widgets/ai_message.dart';
import 'package:friend_private/src/common_widget/card.dart';

class ChatPageTest extends StatefulWidget {
  final FocusNode textFieldFocusNode;

  const ChatPageTest({
    super.key,
    required this.textFieldFocusNode,
  });

  @override
  State<ChatPageTest> createState() => _ChatPageTestState();
}

class _ChatPageTestState extends State<ChatPageTest>
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
    _scrollController.dispose(); // Dispose of your controllers
    _animationController.dispose();
    super.dispose(); // Call the superclass's dispose method
  }

  @override
  Widget build(BuildContext context) {
    // final textTheme:Theme.of(context).textTheme
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


              //*-- Messages --*//
              return Column(
                children: [
                  // Row for "Today"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10), // Adjust spacing as needed
                    child: Row(
                      children: [
                        Text(
                          "Today",
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.purpleBright,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Expanded(
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

                        // Add a SizedBox to create space between messages (adjust height as needed)
                        const SizedBox(
                            height:
                                10.0); // Adjust height to the space you want

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
                              const SizedBox(
                                  height:
                                      10.0), // Space between this message and the next one
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              UserCard(
                                message: message,
                                // Additional configuration for UserCard if necessary
                              ),
                              const SizedBox(
                                  height:
                                      10.0), // Space between this message and the next one
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
