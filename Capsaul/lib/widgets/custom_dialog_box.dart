import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
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
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.blue),
            w8,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.blueGreyDark,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.blueGreyDark,
            ),
          ),
          h8,
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
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
          label: const Text('No'),
        ),
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
          label: const Text('Yes'),
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
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.red),
            w8,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.blueGreyDark,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.blueGreyDark,
            ),
          ),
          h8,
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
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
          label: const Text('Ok'),
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
  final Color? iconColor;

  const CustomDialogWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.yesPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.white,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.blue),
            w8,
            Text(
              maxLines: 2,
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.blueGreyDark,
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.blueGreyDark,
            ),
          ),
          h8,
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
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
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.white),
          label: const Text('No'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: br10,
            ),
          ),
          onPressed: yesPressed,
          icon: const Icon(Icons.check, color: AppColors.white),
          label: const Text('Yes'),
        ),
      ],
    );
  }
}
