import 'dart:async';

import 'package:altio/backend/services/device_flag.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/icon_button.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
    this.onMemorySearch,
    this.isUserMessageSent = false,
    this.hintText,
    this.onBackBtnPressed,
    this.onTabChange,
  });

  final bool? isChat;
  final bool? isMemory;
  final bool isUserMessageSent;
  final Function(String)? onSendMessage;
  final Function(int)? onTabChange;
  final Function(String)? onMemorySearch;
  final String? hintText;
  final VoidCallback? onBackBtnPressed;

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode chatTextFieldFocusNode = FocusNode();
  final FocusNode searchTextFieldFocusNode = FocusNode();
  late bool isMemoryVisible;
  late bool isChatVisible;
  bool isExpanded = false;
  Timer? _debounce;
  int _currentTabIndex = 2;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    isMemoryVisible = false;
    isChatVisible = true;
    isExpanded = true;
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (widget.onMemorySearch != null) {
        widget.onMemorySearch!(_searchController.text.trim());
      }
    });
  }

  void toggleSearchVisibility() {
    setState(() {
      isExpanded = true;
      isMemoryVisible = true;
      isChatVisible = false;
      _currentTabIndex = 2;
      widget.onTabChange?.call(0);
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      isExpanded = true;
      isChatVisible = true;
      isMemoryVisible = false;
      _currentTabIndex = 2;
      widget.onTabChange?.call(2);
    });
  }

  void collapse() {
    setState(() {
      isExpanded = false;
      isMemoryVisible = false;
      isChatVisible = false;
      _currentTabIndex = 0;
    });
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage?.call(message);
      _messageController.clear();
    }
  }

  void _handleSearchMessage(String query) {
    widget.onMemorySearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.015,
                left: MediaQuery.of(context).size.width * 0.005,
                right: MediaQuery.of(context).size.width * 0.005),
            child: GestureDetector(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: br15,
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    const BoxShadow(
                      color: Color.fromARGB(118, 122, 122, 122),
                      blurRadius: 5,
                      offset: Offset(0, 5),
                    ),
                  ],
                  color: AppColors.commonPink,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _currentTabIndex == 0 && deviceProvider.hasDevice == true
                        ? _actionItems()
                        : _buildHomeBtn(),
                    if (!isExpanded && deviceProvider.hasDevice == true)
                      _buildSearchButton(),
                    if (!isExpanded) _buildMessageButton(),
                    if (!isExpanded && deviceProvider.hasDevice == true)
                      _aboutYou(),
                    if (isExpanded && (isMemoryVisible || isChatVisible))
                      _buildExpandedSection(textTheme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (widget.onTabChange != null) {
            widget.onTabChange!(0);
            collapse();
            _currentTabIndex = 0;
          }
        },
        child: Image.asset(
          AppImages.home,
          width: 24.h,
        ),
      ),
    );
  }

  Widget _actionItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (widget.onTabChange != null) {
            widget.onTabChange!(1);
            collapse();
            _currentTabIndex = 1;
          }
        },
        child: Image.asset(
          AppImages.checklist,
          width: 25.5.h,
        ),
      ),
    );
  }

  Widget _aboutYou() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GestureDetector(
        onTap: () {
          if (widget.onTabChange != null) {
            widget.onTabChange!(3);
            _currentTabIndex = 3;
          }
        },
        child: Image.asset(
          AppImages.user,
          width: 25.h,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomIconButton(
        iconPath: AppImages.search,
        size: 24.h,
        onPressed: toggleSearchVisibility,
      ),
    );
  }

  Widget _buildMessageButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomIconButton(
        iconPath: AppImages.message,
        size: 24.h,
        onPressed: toggleMessageVisibility,
      ),
    );
  }

  Widget _buildExpandedSection(TextTheme textTheme) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: br10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 14, height: 1.2),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 3,
                minLines: 1,
                controller: isChatVisible
                    ? _messageController
                    : (isMemoryVisible ? _searchController : null),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  isDense: true,
                  hintText: isChatVisible
                      ? 'Ask Capsaul anything...'
                      : 'Search for memories...',
                  hintStyle: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.greyLight),
                  border: InputBorder.none,
                ),
              ),
            ),
            widget.isUserMessageSent
                ? const TypingIndicator(dotWidth: 6, dotHeight: 6)
                : ClipRRect(
                    borderRadius: br8,
                    child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.rectangle, color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      child: CustomIconButton(
                        size: 24.h,
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
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
