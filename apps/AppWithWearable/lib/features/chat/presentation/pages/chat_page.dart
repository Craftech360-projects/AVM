import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:friend_private/pages/chat/widgets/ai_message.dart';
import 'package:friend_private/pages/chat/widgets/user_message.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ChatPageTest extends StatefulWidget {
  final FocusNode textFieldFocusNode;

  const ChatPageTest({
    super.key,
    required this.textFieldFocusNode,
  });

  @override
  State<ChatPageTest> createState() => _ChatPageTestState();
}

class _ChatPageTestState extends State<ChatPageTest> {
  final TextEditingController _aiChatController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late ChatBloc _chatBloc;
  @override
  void initState() {
    super.initState();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _chatBloc.add(LoadInitialChat());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatLoaded) {
          return _buildChatContent(context, state.messages);
        } else if (state is ChatError) {
          return Center(child: Text(state.error));
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildChatContent(BuildContext context, List<Message> messages) {
    return Stack(
      children: [
        //* Chats Conversation Displaying
        SingleChildScrollView(
          controller: scrollController,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messages.length,
            itemBuilder: (context, chatIndex) {
              final message = messages[chatIndex];
              final isLastMessage = chatIndex == messages.length - 1;
              double topPadding = chatIndex == 0 ? 24 : 16;
              double bottomPadding = isLastMessage
                  ? (widget.textFieldFocusNode.hasFocus ? 120 : 200)
                  : 0;
              _moveListToBottom(
                  extra: widget.textFieldFocusNode.hasFocus ? 148 : 200);

              return Padding(
                key: ValueKey(message.id),
                padding: EdgeInsets.only(
                    bottom: bottomPadding,
                    left: 18,
                    right: 18,
                    top: topPadding),
                child: message.senderEnum == MessageSender.ai
                    ? AIMessage(
                        message: message,
                        sendMessage: (msg) =>
                            context.read<ChatBloc>().add(SendMessage(msg)),
                        displayOptions: messages.length <= 1,
                        memories: message.memories,
                        pluginSender: SharedPreferencesUtil()
                            .pluginsList
                            .firstWhereOrNull((e) => e.id == message.pluginId),
                      )
                    : HumanMessage(message: message),
              );
            },
          ),
        ),
        //* Ask AVM
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            margin: EdgeInsets.only(
                left: 18,
                right: 18,
                bottom: widget.textFieldFocusNode.hasFocus ? 40 : 120),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: GradientBoxBorder(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(127, 208, 208, 208),
                  Color.fromARGB(127, 188, 99, 121),
                  Color.fromARGB(127, 86, 101, 182),
                  Color.fromARGB(127, 126, 190, 236)
                ]),
                width: 1,
              ),
              shape: BoxShape.rectangle,
            ),
            child: TextField(
              enabled: true,
              controller: _aiChatController,
              obscureText: false,
              focusNode: widget.textFieldFocusNode,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Ask your AVM anything',
                hintStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                suffixIcon: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return IconButton(
                      splashColor: Colors.transparent,
                      splashRadius: 1,
                      onPressed: () {
                        if (state is ChatLoading) {
                          return;
                        } else {
                          String message = _aiChatController.text;

                          if (message.isEmpty) return;

                          BlocProvider.of<ChatBloc>(context)
                              .add(SendMessage(message));
                          _aiChatController.clear();
                        }
                      },
                      icon: state is ChatLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Color(0xFFF7F4F4),
                              size: 24.0,
                            ),
                    );
                  },
                ),
              ),
              style: TextStyle(fontSize: 14.0, color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  _moveListToBottom({double extra = 0}) async {
    try {
      scrollController
          .jumpTo(scrollController.position.maxScrollExtent + extra);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
