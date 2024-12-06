import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';
import 'package:friend_private/pages/home/custom_scaffold.dart';
import 'package:friend_private/src/core/common_widget/common_widget.dart';
import 'package:friend_private/src/core/common_widget/list_tile.dart';
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
  bool _isLoading = false;
  bool _showAnimatedText = false;

  void _startLoadingAndShowText() {
    setState(() {
      _isLoading = true;
      _showAnimatedText = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _showAnimatedText = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6F5FA),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Today",
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.purpleBright,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Expanded(
                        child: Divider(
                          color: AppColors.purpleBright,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CustomCard(
                        borderRadius: 16,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: CustomListTile(
                          onTap: _startLoadingAndShowText,
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
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (_isLoading || _showAnimatedText)
                          ? const AvmLogo()
                          : const SizedBox.shrink(),
                      SizedBox(width: 8.w),
                      _isLoading
                          ? Lottie.asset(
                              'assets/lottie_animations/loading.json',
                              width: 40.w,
                              height: 40.h,
                              reverse: true,
                            )
                          : _showAnimatedText
                              ? Expanded(
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                                        'sed do eiusmod tempor incididunt ut labore et dolore '
                                        'magna aliqua. Ut enim ad minim veniam, quis nostrud '
                                        'exercitation ullamco laboris nisi ut aliquip ex ea '
                                        'officia deserunt mollit anim id est laborum.',
                                        textStyle:
                                            textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.normal,
                                          wordSpacing: 0.5,
                                          letterSpacing: 0.5,
                                        ),
                                        speed: const Duration(milliseconds: 4),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: const CustomNavBar(
                isChat: true,
                isMemory: false,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
