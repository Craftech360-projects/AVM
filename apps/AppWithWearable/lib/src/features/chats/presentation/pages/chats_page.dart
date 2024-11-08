import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/core/utils/prompts/chat_prompt.dart';
import 'package:friend_private/src/features/chats/presentation/widgets/avm_logo.dart';
import 'package:friend_private/src/features/home/presentation/pages/navbar.dart';
import 'package:lottie/lottie.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});
  static const String name = 'chatPage';

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = BlocProvider.of<ChatBloc>(context);
    _chatBloc.add(LoadInitialChat()); // Load messages when page opens
  }

  void _sendMessage(String message) {
    print("heree>>>>>");
    _chatBloc.add(SendMessage(message));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F5FA),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final isLoading = state.status == ChatStatus.loading;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display chat history
                        if (state.messages?.isNotEmpty ?? false)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.messages?.length ?? 0,
                            itemBuilder: (context, index) {
                              final message = state.messages![index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message.sender == 'ai') const AvmLogo(),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: message.sender == 'ai'
                                          ? Container(
                                              padding: EdgeInsets.all(12.w),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                message.text,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  wordSpacing: 0.5,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            )
                                          : CustomCard(
                                              borderRadius: 16,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w),
                                              child: ListTile(
                                                title: Text(
                                                  message.text,
                                                  style: textTheme.bodyMedium,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        // Display prompts if there is only one message
                        if ((state.messages?.length ?? 0) <= 1)
                          ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return CustomCard(
                                borderRadius: 16,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: CustomListTile(
                                  onTap: () => _sendMessage(chatPrompt[index]),
                                  title: Text(
                                    chatPrompt[index],
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              );
                            },
                            itemCount: chatPrompt.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                          ),

                        if (isLoading)
                          Row(
                            children: [
                              const AvmLogo(),
                              SizedBox(width: 8.w),
                              Lottie.asset(
                                'assets/lottie_animations/loading.json',
                                width: 40.w,
                                height: 40.h,
                                reverse: true,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: CustomNavBar(
                  isChat: true,
                  isMemory: false,
                  onSendMessage: _sendMessage,
                  //  isLoading: isLoading // Pass the _sendMessage function
                ),
              ),
              SizedBox(height: 12.h),
            ],
          );
        },
      ),
    );
  }
}






// class ChatsPage extends StatefulWidget {
//   const ChatsPage({super.key});
//   static const String name = 'chatPage';

//   @override
//   State<ChatsPage> createState() => _ChatsPageState();
// }

// class _ChatsPageState extends State<ChatsPage> {
//   late ChatBloc _chatBloc;

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = BlocProvider.of<ChatBloc>(context);
//     _chatBloc.add(LoadInitialChat());
//   }

//   void _sendMessage(String message) {
//     _chatBloc.add(SendMessage(message));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return CustomScaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFE6F5FA),
//       ),
//       body: BlocBuilder<ChatBloc, ChatState>(
//         builder: (context, state) {
//           final isLoading = state.status == ChatStatus.loading;
//           final showAnimatedText = state.status == ChatStatus.loaded;

//           return Column(
//             children: [
//               SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 14.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Today",
//                             style: textTheme.bodySmall?.copyWith(
//                               color: CustomColors.purpleBright,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           const Expanded(
//                             child: Divider(
//                               color: CustomColors.purpleBright,
//                               thickness: 0.5,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Show `ListView` only if there is 0 or 1 message
//                       if ((state.messages?.length ?? 0) <= 1)
//                         ListView.separated(
//                           padding: EdgeInsets.symmetric(vertical: 16.h),
//                           physics: const NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return CustomCard(
//                               borderRadius: 16,
//                               padding: EdgeInsets.symmetric(horizontal: 12.w),
//                               child: CustomListTile(
//                                 onTap: () => _sendMessage(chatPrompt[index]),
//                                 title: Text(
//                                   chatPrompt[index],
//                                   style: textTheme.bodyMedium,
//                                 ),
//                               ),
//                             );
//                           },
//                           itemCount: chatPrompt.length,
//                           separatorBuilder: (context, index) =>
//                               SizedBox(height: 12.h),
//                         ),

//                       SizedBox(height: 12.h),

//                       // Display loading or animated text based on state
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (isLoading || showAnimatedText) const AvmLogo(),
//                           SizedBox(width: 8.w),
//                           if (isLoading)
//                             Lottie.asset(
//                               'assets/lottie_animations/loading.json',
//                               width: 40.w,
//                               height: 40.h,
//                               reverse: true,
//                             )
//                           else if (showAnimatedText)
//                             Expanded(
//                               child: AnimatedTextKit(
//                                 animatedTexts: [
//                                   TyperAnimatedText(
//                                     'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
//                                     textStyle: textTheme.bodyMedium?.copyWith(
//                                       fontWeight: FontWeight.normal,
//                                       wordSpacing: 0.5,
//                                       letterSpacing: 0.5,
//                                     ),
//                                     speed: const Duration(milliseconds: 50),
//                                   ),
//                                 ],
//                                 isRepeatingAnimation: false,
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const Spacer(),

//               // Bottom Navigation Bar
//               Center(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 14.w),
//                   child: const CustomNavBar(
//                     isChat: true,
//                     isMemory: false,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12.h),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }