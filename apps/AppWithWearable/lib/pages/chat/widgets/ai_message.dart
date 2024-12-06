import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/message.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';
import 'package:friend_private/src/features/chats/presentation/widgets/avm_logo.dart';
import 'package:friend_private/src/features/memories/presentation/pages/memory_detail_page.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:intl/intl.dart';

class AIMessage extends StatelessWidget {
  final Message message;
  final Function(String) sendMessage;
  final bool displayOptions;
  final List<Memory> memories;
  final Plugin? pluginSender;

  const AIMessage({
    super.key,
    required this.message,
    required this.sendMessage,
    required this.displayOptions,
    required this.memories,
    this.pluginSender,
  });

  @override
  Widget build(BuildContext context) {
    bool isMemoriesEmpty = memories.isEmpty;

    // Print message and memories
    print('Incoming message: ${message.text}');
    for (var element in memories) {
      if (element.structured.target != null) {
        print('Memory at AI: ${element.structured.target!.title}');
      } else {
        print('Memory is null');
      }
    }
    for (var element in memories) {
      print('memories at ai ${element.structured.target!.title}');
    }

    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pluginSender != null
            ? CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(pluginSender!.getImageUrl()),
              )
            : Container(
                decoration: const BoxDecoration(
                    // image: DecorationImage(
                    //   image: AssetImage("assets/images/background.png"),
                    //   fit: BoxFit.cover,
                    // ),
                    // borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                height: 32.h,
                width: 32.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image.asset(
                    //   "assets/images/herologo.png",
                    //   height: 24,
                    //   width: 24,
                    //),
                    const AvmLogo(),
                    SizedBox(width: 8.w),
                  ],
                ),
              ),
        const SizedBox(width: 16.0),
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: AppColors.greyLight, // Or your theme's primary color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.r),
                topRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ) // Smaller radius for chat bubble effect) // Optional: add border radius
              ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              message.typeEnum == MessageType.daySummary
                  ? Text(
                      '📅  Day Summary ~ ${dateTimeFormat('MMM, dd', DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  : const SizedBox(),
              message.typeEnum == MessageType.daySummary
                  ? const SizedBox(height: 16)
                  : const SizedBox(),
              SelectionArea(
                  child: AutoSizeText(
                message.text.isEmpty
                    ? '...'
                    : message.text
                        .replaceAll(r'\n', '\n')
                        .replaceAll('**', '')
                        .replaceAll('\\"', '\"'),
                style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white),
              )),
              // if (isMemoriesEmpty) ..._getInitialOptions(context),
              if (message.id != 1) _getCopyButton(context),
              if (message.id == 1 && displayOptions) const SizedBox(height: 8),
              if (message.id == 1 && displayOptions)
                ..._getInitialOptions(context),
              if (memories.isNotEmpty) ...[
                const SizedBox(height: 16),
                for (var memory in (memories.length > 3
                    ? memories.reversed.toList().sublist(0, 3)
                    : memories.reversed.toList())) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 4.0),
                    child: GestureDetector(
                      onTap: () async {
                        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                        MixpanelManager().chatMessageMemoryClicked(memory);
                        int memoryIndex =
                            memories.reversed.toList().indexOf(memory);
                        print(
                            '>>>>>>>>>>>>>>>>chat memory index clicked $memoryIndex');
                        // BlocProvider.of<MemoryBloc>(context)
                        //     .add(MemoryIndexChanged(memoryIndex: memoryIndex));
                        // await Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (c) => CustomMemoryDetailPage(
                        //           memoryBloc: context.read<MemoryBloc>(),
                        //           memoryAtIndex: memoryIndex,
                        //         )));
                        BlocProvider.of<MemoryBloc>(context)
                            .add(MemoryIndexChanged(memoryIndex: memoryIndex));
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MemoryDetailPage(
                              memoryBloc: BlocProvider.of<MemoryBloc>(context),
                              memoryAtIndex: memoryIndex,
                            ),
                          ),
                        );
                        // TODO: maybe refresh memories here too
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: AppColors.greyOffWhite,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                memory.structured.target!.title,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (message?.createdAt != null) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(
                                        message!.createdAt), // Format time
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  // Icon(
                                  //   Icons.done_all, // Or your preferred status icon
                                  //   size: 14.sp,
                                  //   color: Colors.white70,
                                  // ),
                                ],
                              ),
                            ],
                            const Icon(Icons.arrow_right_alt)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        )),
      ],
    );
  }

  _getCopyButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: message.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Response copied to clipboard.',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 12.0,
                ),
              ),
              duration: Duration(milliseconds: 2000),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
              child: Icon(
                Icons.content_copy,
                color: Theme.of(context).textTheme.bodySmall!.color,
                size: 10.0,
              ),
            ),
            Text(
              'Copy response',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  _getInitialOption(BuildContext context, String optionText) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
            bottomRight:
                Radius.circular(5.r), // Smaller radius for chat bubble effect
          ),
        ),
        child: Text(optionText, style: Theme.of(context).textTheme.bodyMedium),
      ),
      onTap: () {
        print("sending");
        try {
          // sendMessage(optionText);
          // BlocProvider.of<ChatBloc>(context).add(SendMessage(optionText));
          BlocProvider.of<ChatBloc>(context).add(SendMessage(optionText));
        } catch (e) {
          print("error,$e");
        }
        print('here');
      },
    );
  }

  _getInitialOptions(BuildContext context) {
    return [
      const SizedBox(height: 8),
      _getInitialOption(context, 'Which tasks are due today or tomorrow?'),
      const SizedBox(height: 8),
      _getInitialOption(
          context, 'What progress did I make on yesterday tasks?'),
      const SizedBox(height: 8),
      _getInitialOption(context,
          'Can you summarize the latest tips on growing my business??'),
      const SizedBox(height: 8),
      _getInitialOption(context,
          'What new skills or knowledge did I gain from recent discussions?'),
    ];
  }
}
