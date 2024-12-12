import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/core/constants/constants.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/src/common_widget/elevated_button.dart';

class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onSkip,
    required this.onPressed,
  });
  final String message;
  final String buttonText;
  final VoidCallback onSkip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  message,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w500, height: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(4.h),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(30.h)),
              border: Border.all(color: AppColors.black)
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.2),
              //     offset: const Offset(0, 4),
              //     blurRadius: 10,
              //     spreadRadius: 1,
              //   ),
              // ],
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 24.h,
                  color: AppColors.black,
                ),
                onPressed: onSkip,
              ),
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  width: double.maxFinite,
                  child: CustomElevatedButton(
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        h15,
      ],
    );
  }
}
