// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:friend_private/backend/database/message.dart';
// import 'package:friend_private/backend/preferences.dart';
// import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
// import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
// import 'package:friend_private/pages/chat/widgets/ai_message.dart';
// import 'package:friend_private/pages/chat/widgets/user_message.dart';
// import 'package:gradient_borders/box_borders/gradient_box_border.dart';

// class ChatPageTest extends StatefulWidget {
//   final FocusNode textFieldFocusNode;

//   const ChatPageTest({
//     super.key,
//     required this.textFieldFocusNode,
//   });

//   @override
//   State<ChatPageTest> createState() => _ChatPageTestState();
// }

// class _ChatPageTestState extends State<ChatPageTest>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _aiChatController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   late ChatBloc _chatBloc;
//   late AnimationController _animationController;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = BlocProvider.of<ChatBloc>(context);
//     _chatBloc.add(LoadInitialChat());

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToEnd();
//     });

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat();

//     _animation =
//         Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
//   }

//   void _scrollToEnd() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose(); // Dispose of your controllers
//     _animationController.dispose();
//     super.dispose(); // Call the superclass's dispose method
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         BlocBuilder<ChatBloc, ChatState>(
//           bloc: _chatBloc,
//           buildWhen: (previous, current) =>
//               previous.messages?.length != current.messages?.length,
//           builder: (context, state) {
//             if (state.status == ChatStatus.loaded) {
//               WidgetsBinding.instance.addPostFrameCallback(
//                 (_) {
//                   _scrollToEnd();
//                 },
//               );
//               //*-- Messages --*//
//               return ListView.builder(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.only(
//                   left: 20,
//                   right: 20,
//                   bottom: 130,
//                 ),
//                 itemCount: state.messages?.length ?? 0,
//                 itemBuilder: (context, index) {
//                   final message = state.messages?[index];
//               //  message!.memories.map((f)=>print('messages at chatpage ${f.structured.target!.title}'));
//                   if (message?.senderEnum == MessageSender.ai) {
//                     return AIMessage(
//                       message: message!,
//                       sendMessage: (msg) {
//                         // print('send Message ${message.text}');
//                         // context.read<ChatBloc>().add(SendMessage(msg));
//                       },
//                       displayOptions: state.messages!.length <= 1,
//                       memories: message.memories,
//                       // memories: message.memories,
//                       pluginSender: SharedPreferencesUtil()
//                           .pluginsList
//                           .firstWhereOrNull((e) => e.id == message.pluginId),
//                     );
//                   } else {
//                     return HumanMessage(message: message!);
//                   }
//                 },
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//         //*-- Ask AVM --*//
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: AnimatedBuilder(
//             animation: _animationController,
//             builder: (context, child) {
//               return Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//                 margin: EdgeInsets.only(
//                   left: 18,
//                   right: 18,
//                   bottom: 70,
//                   // bottom: widget.textFieldFocusNode.hasFocus ? 40 : 70,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: const BorderRadius.all(Radius.circular(16)),
//                   border: GradientBoxBorder(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color.lerp(
//                           const Color.fromARGB(233, 208, 208, 208),
//                           const Color.fromARGB(227, 255, 255, 255),
//                           _animation.value,
//                         )!,
//                         Color.lerp(
//                           const Color.fromARGB(227, 255, 255, 255),
//                           const Color.fromARGB(255, 89, 90, 92),
//                           _animation.value,
//                         )!,
//                         Color.lerp(
//                           const Color.fromARGB(255, 89, 90, 92),
//                           const Color.fromARGB(233, 208, 208, 208),
//                           _animation.value,
//                         )!,
//                         // Color.lerp(
//                         //   const Color.fromARGB(255, 34, 34, 34),
//                         //   const Color.fromARGB(233, 208, 208, 208),
//                         //   _animation.value,
//                         // )!,
//                       ],
//                     ),
//                     width: 1,
//                   ),
//                 ),
//                 child: child,
//               );
//             },
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _aiChatController,
//                     focusNode: widget.textFieldFocusNode,
//                     decoration: const InputDecoration(
//                       hintText: 'Ask your AVM anything',
//                       hintStyle: TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.grey,
//                       ),
//                       border: InputBorder.none,
//                     ),
//                     style: TextStyle(
//                       fontSize: 14.0,
//                       color: Colors.grey.shade200,
//                     ),
//                   ),
//                 ),
//                 BlocBuilder<ChatBloc, ChatState>(
//                   builder: (context, state) {
//                     return IconButton(
//                       splashColor: Colors.transparent,
//                       onPressed: state.status == ChatStatus.loading
//                           ? null
//                           : () {
//                               final message = _aiChatController.text.trim();
//                               if (message.isNotEmpty) {
//                                 BlocProvider.of<ChatBloc>(context)
//                                     .add(SendMessage(message));
//                                 _aiChatController.clear();
//                                 _scrollToEnd();
//                               }
//                             },
//                       icon: state.status == ChatStatus.loading
//                           ? const SizedBox(
//                               height: 16,
//                               width: 16,
//                               child: CircularProgressIndicator(
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Icon(Icons.send_rounded),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// /*
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ChatBloc, ChatState>(
//       bloc: _chatBloc,
//       builder: (context, state) {
//         if (state is ChatLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is ChatLoaded) {
//           return _buildChatContent(context, state.messages);
//         } else if (state is ChatError) {
//           return Center(child: Text(state.error));
//         } else {
//           return Container();
//         }
//       },
//     );
//   }
// */
//   // Widget _buildChatContent(BuildContext context, List<Message> messages) {
//   //   return Stack(
//   //     children: [
//   //       //* Chats Conversation Displaying
//   //       SingleChildScrollView(
//   //         controller: scrollController,
//   //         child: ListView.builder(
//   //           shrinkWrap: true,
//   //           physics: const NeverScrollableScrollPhysics(),
//   //           itemCount: messages.length,
//   //           itemBuilder: (context, chatIndex) {
//   //             final message = messages[chatIndex];
//   //             final isLastMessage = chatIndex == messages.length - 1;
//   //             double topPadding = chatIndex == 0 ? 24 : 16;
//   //             double bottomPadding = isLastMessage
//   //                 ? (widget.textFieldFocusNode.hasFocus ? 120 : 200)
//   //                 : 0;
//   //             _moveListToBottom(
//   //                 extra: widget.textFieldFocusNode.hasFocus ? 148 : 200);

//   //             return Padding(
//   //               key: ValueKey(message.id),
//   //               padding: EdgeInsets.only(
//   //                   bottom: bottomPadding,
//   //                   left: 18,
//   //                   right: 18,
//   //                   top: topPadding),
//   //               child: message.senderEnum == MessageSender.ai
//   //                   ? AIMessage(
//   //                       message: message,
//   //                       sendMessage: (msg) =>
//   //                           context.read<ChatBloc>().add(SendMessage(msg)),
//   //                       displayOptions: messages.length <= 1,
//   //                       memories: message.memories,
//   //                       pluginSender: SharedPreferencesUtil()
//   //                           .pluginsList
//   //                           .firstWhereOrNull((e) => e.id == message.pluginId),
//   //                     )
//   //                   : HumanMessage(message: message),
//   //             );
//   //           },
//   //         ),
//   //       ),
//   //       //* Ask AVM
//   //       Align(
//   //         alignment: Alignment.bottomCenter,
//   //         child: Container(
//   //           width: double.maxFinite,
//   //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
//   //           margin: EdgeInsets.only(
//   //               left: 18,
//   //               right: 18,
//   //               bottom: widget.textFieldFocusNode.hasFocus ? 40 : 120),
//   //           decoration: const BoxDecoration(
//   //             color: Colors.black,
//   //             borderRadius: BorderRadius.all(Radius.circular(16)),
//   //             border: GradientBoxBorder(
//   //               gradient: LinearGradient(colors: [
//   //                 Color.fromARGB(127, 208, 208, 208),
//   //                 Color.fromARGB(127, 188, 99, 121),
//   //                 Color.fromARGB(127, 86, 101, 182),
//   //                 Color.fromARGB(127, 126, 190, 236)
//   //               ]),
//   //               width: 1,
//   //             ),
//   //             shape: BoxShape.rectangle,
//   //           ),
//   //           child: TextField(
//   //             enabled: true,
//   //             controller: _aiChatController,
//   //             obscureText: false,
//   //             focusNode: widget.textFieldFocusNode,
//   //             textAlign: TextAlign.start,
//   //             textAlignVertical: TextAlignVertical.center,
//   //             decoration: InputDecoration(
//   //               hintText: 'Ask your AVM anything',
//   //               hintStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
//   //               focusedBorder: InputBorder.none,
//   //               enabledBorder: InputBorder.none,
//   //               suffixIcon: BlocBuilder<ChatBloc, ChatState>(
//   //                 builder: (context, state) {
//   //                   return IconButton(
//   //                     splashColor: Colors.transparent,
//   //                     splashRadius: 1,
//   //                     onPressed: () {
//   //                       if (state is ChatLoading) {
//   //                         return;
//   //                       } else {
//   //                         String message = _aiChatController.text;

//   //                         if (message.isEmpty) return;

//   //                         BlocProvider.of<ChatBloc>(context)
//   //                             .add(SendMessage(message));
//   //                         _aiChatController.clear();
//   //                       }
//   //                     },
//   //                     icon: state is ChatLoading
//   //                         ? const SizedBox(
//   //                             width: 16,
//   //                             height: 16,
//   //                             child: CircularProgressIndicator(
//   //                               valueColor:
//   //                                   AlwaysStoppedAnimation<Color>(Colors.white),
//   //                             ),
//   //                           )
//   //                         : const Icon(
//   //                             Icons.send_rounded,
//   //                             color: Color(0xFFF7F4F4),
//   //                             size: 24.0,
//   //                           ),
//   //                   );
//   //                 },
//   //               ),
//   //             ),
//   //             style: TextStyle(fontSize: 14.0, color: Colors.grey.shade200),
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
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
    _chatBloc.add(
        InitializeDailySummary()); // Trigger the daily summary initialization

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
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 130,
                ),
                itemCount: state.messages?.length ?? 0,
                itemBuilder: (context, index) {
                  final message = state.messages?[index];
                  if (message?.senderEnum == MessageSender.ai) {
                    return AIMessage(
                      message: message!,
                      sendMessage: (msg) {
                        // This line can be uncommented to handle additional sending if needed
                        // context.read<ChatBloc>().add(SendMessage(msg));
                      },
                      displayOptions: state.messages!.length <= 1,
                      memories: message.memories,
                      pluginSender: SharedPreferencesUtil()
                          .pluginsList
                          .firstWhereOrNull((e) => e.id == message.pluginId),
                    );
                  } else {
                    return HumanMessage(message: message!);
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        //*-- Ask AVM --*//
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                margin: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  bottom: 70,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(
                          const Color.fromARGB(233, 208, 208, 208),
                          const Color.fromARGB(227, 255, 255, 255),
                          _animation.value,
                        )!,
                        Color.lerp(
                          const Color.fromARGB(227, 255, 255, 255),
                          const Color.fromARGB(255, 89, 90, 92),
                          _animation.value,
                        )!,
                        Color.lerp(
                          const Color.fromARGB(255, 89, 90, 92),
                          const Color.fromARGB(233, 208, 208, 208),
                          _animation.value,
                        )!,
                      ],
                    ),
                    width: 1,
                  ),
                ),
                child: child,
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aiChatController,
                    focusNode: widget.textFieldFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Ask your AVM anything',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    return IconButton(
                      splashColor: Colors.transparent,
                      onPressed: state.status == ChatStatus.loading
                          ? null
                          : () {
                              final message = _aiChatController.text.trim();
                              if (message.isNotEmpty) {
                                BlocProvider.of<ChatBloc>(context)
                                    .add(SendMessage(message));
                                _aiChatController.clear();
                                _scrollToEnd();
                              }
                            },
                      icon: state.status == ChatStatus.loading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
