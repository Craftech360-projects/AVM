import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Future<bool> customDialogBox(BuildContext context,
    {Color? iconColor,
    required String title,
    required String message,
    required IconData icon,
    VoidCallback? yesPressed}) async {
  bool userResponse = false;
  await showDialog(
    context: context,
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: br12,
      ),
      backgroundColor: AppColors.white,
      title: Container(
        alignment: Alignment.topLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.blue),
              w8,
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.blueGreyDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.2,
                  color: AppColors.blueGreyDark,
                ),
          ),
          h8,
        ],
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: () {
            userResponse = false;
            Navigator.of(c).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.white),
          label: Text(
            'No',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.white),
          ),
        ),
        w4,
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: () {
            userResponse = true;
            Navigator.of(c).pop();
          },
          icon: const Icon(Icons.check, color: AppColors.white),
          label: Text(
            'Yes',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    ),
  );
  return userResponse;
}

void showPermissionDeniedDialog(
    BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: br12,
      ),
      backgroundColor: AppColors.white,
      title: Container(
      alignment: Alignment.topLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.red),
              w8,
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.blueGreyDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(height: 1.2, color: AppColors.blueGreyDark),
          ),
          h8,
        ],
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: () {
            Navigator.of(c).pop();
          },
          icon: const Icon(Icons.check, color: AppColors.white),
          label: Text('Ok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? yesPressed;
  final VoidCallback? noPressed;
  final Color? iconColor;
  final bool showTextField;
  final TextEditingController? textFieldController;
  final String? yesText;
  final String? noText;

  const CustomDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.yesPressed,
    this.noPressed,
    this.textFieldController,
    this.yesText,
    this.noText,
    this.showTextField = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: br12,
      ),
      backgroundColor: AppColors.white,
      title: Container(
      alignment: Alignment.topLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(icon, color: iconColor ?? AppColors.blue),
              w8,
              Text(
                maxLines: 2,
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.blueGreyDark,
                ),
              ),
            ],
          ),
        ),
      ),
      content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.2,
              color: AppColors.blueGreyDark,
            ),
          ),
          if (showTextField) ...[
            h8,
            TextField(
              style: const TextStyle(color: AppColors.white),
              controller: textFieldController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.blueGreyDark.withValues(alpha: 0.5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: br8,
                  borderSide: BorderSide.none,
                ),
                hintText: 'Your name here...',
                hintStyle: const TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.start,
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(60, 40),
            backgroundColor: AppColors.red,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: () {
            noPressed != null ? noPressed!() : Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.white, size: 17),
          label: Text(
            noText ?? 'No',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        w4,
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(60, 40),
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: yesPressed,
          icon: const Icon(Icons.check, color: AppColors.white, size: 17),
          label: Text(
            yesText ?? 'Yes',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
