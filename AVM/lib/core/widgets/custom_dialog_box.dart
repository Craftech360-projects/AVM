import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
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
            w10,
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
              fontSize: 15,
              height: 1.2,
              color: AppColors.blueGreyDark,
            ),
          ),
          h10,
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
            w10,
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
              fontSize: 15,
              height: 1.2,
              color: AppColors.blueGreyDark,
            ),
          ),
          h10,
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
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
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: iconColor ?? AppColors.blue),
            w10,
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
              fontSize: 15,
              height: 1.2,
              color: AppColors.blueGreyDark,
            ),
          ),
          if (showTextField) ...[
            h10,
            TextField(
              cursorColor: AppColors.black,
              style: TextStyle(color: AppColors.white),
              controller: textFieldController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.blueGreyDark.withValues(alpha: 0.5),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: br8,
                  borderSide: BorderSide.none,
                ),
                hintText: 'Your name here...',
                hintStyle: TextStyle(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
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
            noPressed ?? Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close, color: AppColors.white, size: 17),
          label: Text(
            noText ?? 'No',
            style: TextStyle(fontSize: 13),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            minimumSize: const Size(80, 40),
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
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
