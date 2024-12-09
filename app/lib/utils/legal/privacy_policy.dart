import 'package:flutter/material.dart';
import 'package:friend_private/src/common_widget/dialog.dart';

void showPrivacyPolicy(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(
        title: "Privacy Policy",
        content: 'Here goes your lengthy Terms and Conditions text. '
            'Make sure to include all the legal content here for users to read. '
            'You can expand this text as needed, and it will be scrollable within the dialog.'
            '\n\nExample:\n1. Users agree to abide by the app’s rules.\n'
            '2. The app reserves the right to modify terms.\n'
            '3. Users consent to data policies in accordance with privacy laws.\n'
            '...\n'
            'End with any disclaimers or additional information as needed.',
        onCancel: TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        onSubmit: const SizedBox.shrink(),
      );
    },
  );
}
