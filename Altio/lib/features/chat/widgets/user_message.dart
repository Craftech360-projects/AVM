import 'dart:developer';

import 'package:altio/backend/database/message.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:altio/features/chat/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class UserMessage extends StatelessWidget {
  final Message? message;

  const UserMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 2, 0, 2),
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
                        label: Text("Select Message"),
                      ),
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

                            if (!context.mounted) return;

                            if (confirm == true) {
                              context
                                  .read<ChatBloc>()
                                  .add(DeleteMessage(message!));
                            }

                            if (context.mounted) {
                              Navigator.of(context).pop();
                              avmSnackBar(context, "Message deleted");
                            }
                          } catch (e) {
                            log(e.toString());

                            if (context.mounted) {
                              avmSnackBar(context,
                                  "Oops! Something went wrong, Please try again later");
                            }
                          }
                        },
                        label: Text("Delete Message"),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.copy_rounded),
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: message!.text));

                          if (!context.mounted) return;

                          Navigator.of(context).pop();
                          avmSnackBar(
                            context,
                            'Message copied to clipboard',
                          );
                        },
                        label: Text("Copy Message"),
                      ),
                      TextButton.icon(
                          icon: Icon(Icons.push_pin_rounded),
                          onPressed: () async {
                            // context.read<ChatBloc>().add(PinMessage(message!));
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
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: size.width * 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.purpleDark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 08.w,
                    vertical: 05.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message?.text ?? '',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.white,
                          height: 1.2,
                        ),
                      ),
                      h4,
                      if (message?.createdAt != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(message!.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
