import 'dart:developer';

import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/message.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/core/widgets/custom_dialog_box.dart';
import 'package:capsaul/features/chat/bloc/chat_bloc.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/features/memories/pages/memory_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 20, 2),
      child: GestureDetector(
        onLongPress: () async {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: br5),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                          icon: Icon(Icons.check_box_outline_blank_sharp),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: Text("Select Message")),
                      TextButton.icon(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            try {
                              bool? confirm = await customDialogBox(
                                context,
                                icon: Icons.delete,
                                title: 'Delete Message',
                                message:
                                    'Are you sure you want to delete this message? This action cannot be reversed!',
                              );
                              if (confirm) {
                                context
                                    .read<ChatBloc>()
                                    .add(DeleteMessage(message));
                              }
                              Navigator.of(context).pop();
                              avmSnackBar(context, "Message deleted");
                            } catch (e) {
                              log(e.toString());
                              avmSnackBar(context,
                                  "Oops! Something went wrong, Please try again later");
                            }
                          },
                          label: Text("Delete Message")),
                      TextButton.icon(
                          icon: Icon(Icons.copy_rounded),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: message.text));
                            Navigator.of(context).pop();
                            avmSnackBar(
                              context,
                              'Message copied to clipboard',
                            );
                          },
                          label: Text("Copy Message")),
                      TextButton.icon(
                          icon: Icon(Icons.push_pin_rounded),
                          onPressed: () async {
                            context.read<ChatBloc>().add(PinMessage(message));
                            Navigator.of(context).pop();
                            avmSnackBar(context, "Message pinned");
                          },
                          label: Text("Pin Message")),
                    ],
                  ),
                );
              });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            pluginSender != null
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(pluginSender!.getImageUrl()),
                  )
                : Container(
                    height: 35.0,
                    width: 35.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purpleDark,
                    ),
                    child: const Icon(Icons.assistant, color: AppColors.white),
                  ),
            w4,
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 08.w,
                  vertical: 05.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE5E4E2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.typeEnum == MessageType.daySummary)
                      Text(
                        '📅 Day Summary ~ ${DateFormat('MMM, dd').format(DateTime.now())}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        message.text.isEmpty
                            ? '...'
                            : message.text
                                .replaceAll(r'\n', '\n')
                                .replaceAll('**', '')
                                .replaceAll('\\"', '"'),
                        style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            height: 1.2),
                      ),
                    if (message.id == 1 && displayOptions) h4,
                    if (message.id == 1 && displayOptions)
                      ..._getInitialOptions(context),
                    if (memories.isNotEmpty) ...[
                      h16,
                      for (var memory in (memories.length > 3
                          ? memories.reversed.toList().sublist(0, 3)
                          : memories.reversed.toList()))
                        GestureDetector(
                          onTap: () {
                            MixpanelManager().chatMessageMemoryClicked(memory);
                            int memoryIndex =
                                memories.reversed.toList().indexOf(memory);
                            BlocProvider.of<MemoryBloc>(context).add(
                                MemoryIndexChanged(memoryIndex: memoryIndex));
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MemoryDetailPage(
                                  memoryBloc:
                                      BlocProvider.of<MemoryBloc>(context),
                                  memoryAtIndex: memoryIndex,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 02),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.purpleDark,
                              borderRadius: br5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    memory.structured.target!.title,
                                    style: TextStyle(
                                        fontSize: 13, color: AppColors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(memory.createdAt),
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getInitialOption(BuildContext context, String optionText) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Color(0xFFF8F8FF),
          borderRadius: br15,
        ),
        child: Text(optionText, style: Theme.of(context).textTheme.bodyMedium),
      ),
      onTap: () {
        try {
          BlocProvider.of<ChatBloc>(context).add(SendMessage(optionText));
        } catch (e) {
          log("error,$e");
        }
      },
    );
  }

  _getInitialOptions(BuildContext context) {
    return [
      h4,
      _getInitialOption(context, 'Which tasks are due today or tomorrow?'),
      h4,
      _getInitialOption(
          context, 'What progress did I make on yesterday tasks?'),
      h4,
      _getInitialOption(context,
          'Can you summarize the latest tips on growing my business??'),
      h4,
      _getInitialOption(context,
          'What new skills or knowledge did I gain from recent discussions?'),
    ];
  }
}