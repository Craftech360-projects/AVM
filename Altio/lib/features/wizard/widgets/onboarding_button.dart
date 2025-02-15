import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/elevated_button.dart';
import 'package:flutter/material.dart';

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
                  style: textTheme.bodyLarge?.copyWith(height: 1.2),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: br15,
              border: Border.all(color: AppColors.black)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 24,
                  color: AppColors.black,
                ),
                onPressed: onSkip,
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  width: double.maxFinite,
                  child: CustomElevatedButton(
                    onPressed: onPressed,
                    child: Text(buttonText,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: AppColors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
