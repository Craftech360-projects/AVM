import 'package:auto_size_text/auto_size_text.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/message.dart';
import 'package:capsoul/backend/mixpanel.dart';
import 'package:capsoul/backend/schema/plugin.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/features/chat/bloc/chat_bloc.dart';
import 'package:capsoul/features/memories/bloc/memory_bloc.dart';
import 'package:capsoul/features/memories/pages/memory_detail_page.dart';
import 'package:capsoul/utils/other/temp.dart';
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
    bool isLoading = message.text.isEmpty;

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If pluginSender exists, show its image, else show a placeholder
        pluginSender != null
            ? CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(pluginSender!.getImageUrl()),
              )
            : Container(
                decoration: const BoxDecoration(),
                height: 32.h,
                width: 32.w,
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    w10,
                  ],
                ),
              ),
        w15,
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(3.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              h5,
              if (message.typeEnum == MessageType.daySummary)
                Text(
                  '📅 Day Summary ~ ${dateTimeFormat('MMM, dd', DateTime.now())}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SelectionArea(
                  child: AutoSizeText(
                    message.text.isEmpty
                        ? '...'
                        : message.text
                            .replaceAll(r'\n', '\n')
                            .replaceAll('**', '')
                            .replaceAll('\\"', '"'),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              // Show copy button only if it's not the first message
              if (message.id != 1) _getCopyButton(context),
              if (message.id == 1 && displayOptions) const SizedBox(height: 8),
              if (message.id == 1 && displayOptions)
                ..._getInitialOptions(context),
              // Show memories if available
              if (memories.isNotEmpty) ...[
                h15,
                for (var memory in (memories.length > 3
                    ? memories.reversed.toList().sublist(0, 3)
                    : memories.reversed.toList())) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 4.0),
                    child: GestureDetector(
                      onTap: () async {
                        MixpanelManager().chatMessageMemoryClicked(memory);
                        int memoryIndex =
                            memories.reversed.toList().indexOf(memory);

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
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: AppColors.greyOffWhite,
                          borderRadius: br12,
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
                            w10,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(memory.createdAt),
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                )
                              ],
                            ),
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
          avmSnackBar(
            context,
            'Response copied to clipboard',
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
                size: 12.0,
              ),
            ),
            const Text(
              'Copy response',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
          color: Colors.grey.shade200,
          borderRadius: br15,
        ),
        child: Text(optionText, style: Theme.of(context).textTheme.bodyMedium),
      ),
      onTap: () {
        try {
          BlocProvider.of<ChatBloc>(context).add(SendMessage(optionText));
        } catch (e) {
          debugPrint("error,$e");
        }
      },
    );
  }

  _getInitialOptions(BuildContext context) {
    return [
      h5,
      _getInitialOption(context, 'Which tasks are due today or tomorrow?'),
      h5,
      _getInitialOption(
          context, 'What progress did I make on yesterday tasks?'),
      h5,
      _getInitialOption(context,
          'Can you summarize the latest tips on growing my business??'),
      h5,
      _getInitialOption(context,
          'What new skills or knowledge did I gain from recent discussions?'),
    ];
  }
}
