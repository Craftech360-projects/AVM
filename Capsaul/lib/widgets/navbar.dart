import 'dart:async';

import 'package:capsaul/core/assets/app_images.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/core/widgets/typing_indicator.dart';
import 'package:capsaul/features/capture/presentation/capture_page.dart';
import 'package:capsaul/features/chat/presentation/chat_screen.dart';
import 'package:capsaul/src/common_widget/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({
    super.key,
    this.isChat = false,
    this.isMemory = false,
    this.onSendMessage,
    this.onMemorySearch,
    this.isUserMessageSent = false,
  });

  final bool? isChat;
  final bool? isMemory;
  final bool isUserMessageSent;
  final Function(String)? onSendMessage;
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
  FocusNode chatTextFieldFocusNode = FocusNode(canRequestFocus: true);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    isMemoryVisible = false;
    isChatVisible = false;
    isExpanded = false;
  }

  Timer? _debounce;

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
    });
  }

  void toggleMessageVisibility() {
    setState(() {
      isExpanded = true;
      isChatVisible = true;
      isMemoryVisible = false;
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
    if (message.isNotEmpty) {
      widget.onSendMessage?.call(message);
      _messageController.clear();
    }
  }

  void _handleSearchMessage(String query) {
    widget.onMemorySearch?.call(query);
  }

  void _navigateToCaptureScreen() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => CapturePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: fadeInAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToChatScreen() {
    toggleMessageVisibility(); // Add this line before navigation
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(textFieldFocusNode: chatTextFieldFocusNode, shouldExpandNavbar: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: fadeInAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.010,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: GestureDetector(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: br15,
            border: Border.all(
              color: AppColors.white,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
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
              if (!isExpanded) _buildLogo(),
              if (!isExpanded) _buildVerticalDivider(),
              if (isExpanded) _buildHomeBtn(),
              if (!isExpanded) _buildSearchButton(),
              if (!isExpanded) _buildMessageButton(),
              if (isExpanded && (isMemoryVisible || isChatVisible))
                _buildExpandedSection(textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: GestureDetector(
        onTap: _navigateToCaptureScreen,
        child: Image.asset(
          AppImages.appLogo,
          height: 16.h,
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return VerticalDivider(
      thickness: 0.5.w,
      width: 0,
      color: AppColors.brightGrey,
      endIndent: 8.h,
      indent: 8.h,
    );
  }

  Widget _buildHomeBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: GestureDetector(
        onTap: _navigateToCaptureScreen,
        child: Image.asset(
          AppImages.home,
          width: 24.h,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: CustomIconButton(
        iconPath: AppImages.search,
        size: 24.h,
        onPressed: toggleSearchVisibility,
      ),
    );
  }

  Widget _buildMessageButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: CustomIconButton(
        iconPath: AppImages.message,
        size: 24.h,
        onPressed: _navigateToChatScreen,
      ),
    );
  }

  Widget _buildExpandedSection(TextTheme textTheme) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 02, right: 05),
        height: 60.h,
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
                style: TextStyle(fontSize: 14, height: 1.2),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 3,
                minLines: 1,
                controller: isChatVisible
                    ? _messageController
                    : (isMemoryVisible ? _searchController : null),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                ? TypingIndicator(dotWidth: 6, dotHeight: 6)
                : ClipRRect(
                    borderRadius: br8,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle, color: AppColors.white),
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
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
    super.dispose();
  }
}
