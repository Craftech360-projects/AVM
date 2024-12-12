import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core/assets/app_images.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/src/common_widget/icon_button.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
    this.onTabChange,
    this.onMemorySearch,
  });
  final bool? isChat;
  final bool? isMemory;
  final Function(String)? onSendMessage;
  final Function(int)? onTabChange;
  final Function(String)? onMemorySearch;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late bool isMemoryVisible;
  late bool isChatVisible;
  bool isExpanded = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (widget.onMemorySearch != null && isMemoryVisible) {
        widget.onMemorySearch!(_searchController.text);
      }
    });

    isMemoryVisible = false;
    isChatVisible = false;
    isExpanded = false;
  }

  void toggleSearchVisibility() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
      }
      isMemoryVisible = true;
      isChatVisible = false;
      if (widget.onTabChange != null) {
        widget.onTabChange!(0);
      }
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      if (!isExpanded) {
        isExpanded = true;
      }
      isChatVisible = true;
      isMemoryVisible = false;
      if (widget.onTabChange != null) {
        widget.onTabChange!(1);
      }
    });
  }

  void collapse() {
    setState(() {
      isExpanded = false;
      isMemoryVisible = false;
      isChatVisible = false;
    });
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && widget.onSendMessage != null) {
      widget.onSendMessage!(message);
      _messageController.clear();
    }
  }

  void _handleSearchMessage(String query) {
    if (widget.onMemorySearch != null) {
      widget.onMemorySearch!(query);
    } else {
      log("its empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.h),
            border: Border.all(
              color: AppColors.white,
              width: 1.w,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(118, 122, 122, 122),
                blurRadius: 4,
                offset: Offset(0, 5),
              ),
            ],
            color: AppColors.commonPink,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            // mainAxisSize: MainAxisSize.max,
            children: [
              // AVA Icon
              if (!isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onTabChange != null) {
                        widget.onTabChange!(0); // Navigate to Tab 0
                      }
                    },
                    child: Image.asset(
                      AppImages.appLogo,
                      height: 13.h,
                    ),
                  ),
                ),
              if (!isExpanded)
                VerticalDivider(
                  thickness: 0.5.w,
                  width: 0,
                  color: AppColors.brightGrey,
                  endIndent: 8.h,
                  indent: 8.h,
                ),
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: GestureDetector(
                    onTap: () {
                      if (isExpanded) {
                        // Collapse the expanded section
                        setState(() {
                          isExpanded = false;
                          isMemoryVisible = false;
                          isChatVisible = false;
                        });
                      } else {
                        setState(() {
                          isExpanded = true;
                        });
                      }
                    },
                    child: Image.asset(
                      AppImages.appLogo,
                      height: 13.h,
                    ),
                  ),
                ),

              // Home Icon with collapse functionality
              if (!isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomIconButton(
                    iconPath: AppImages.search,
                    size: 22.h,
                    onPressed: isExpanded ? collapse : toggleSearchVisibility,
                  ),
                ),
              if (!isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: CustomIconButton(
                    iconPath: AppImages.message,
                    size: 22.h,
                    onPressed: isExpanded ? collapse : toggleMessageVisibility,
                  ),
                ),
              // Expanded search/chat section
              if (isExpanded && (isMemoryVisible || isChatVisible))
                Expanded(
                  child: Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: isChatVisible
                                ? _messageController
                                : (isMemoryVisible ? _searchController : null),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 15.h),
                              hintText: isChatVisible
                                  ? 'Ask your AVM anything...'
                                  : 'Search for memories...',
                              hintStyle: textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.greyLight),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        // Trailing (Button or Icon)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.h),
                          child: Container(
                            color: AppColors.greyLavender,
                            padding: EdgeInsets.all(4.h),
                            child: CustomIconButton(
                              size: 22.h,
                              iconPath: AppImages.send,
                              onPressed: isChatVisible
                                  ? _handleSendMessage
                                  : () => _handleSearchMessage(
                                        _searchController.text.trim(),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
