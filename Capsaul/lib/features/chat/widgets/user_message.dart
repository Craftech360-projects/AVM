import 'package:capsaul/backend/database/message.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
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
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(0.r),
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
                        fontSize: 13,
                        color: AppColors.white,
                        height: 1.3,
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
                              fontSize: 10,
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
    );
  }
}
