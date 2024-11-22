import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/src/core/constant/constant.dart';

getDialog(
  BuildContext context,
  Function onCancel,
  Function onConfirm,
  String title,
  String content, {
  bool singleButton = false,
  String okButtonText = 'Ok',
}) {
  var actions = singleButton
      ? [
          TextButton(
            onPressed: () => onCancel(),
            child:
                Text(okButtonText, style: const TextStyle(color: Colors.white)),
          )
        ]
      : [
          TextButton(
            onPressed: () => onCancel(),
            child:
                const Text('Cancel', style: TextStyle(color: CustomColors.red)),
          ),
          TextButton(
              onPressed: () => onConfirm(),
              child: const Text('Confirm',
                  style: TextStyle(color: CustomColors.blackPrimary))),
        ];
  if (Platform.isIOS) {
    return CupertinoAlertDialog(
        title: Text(title), content: Text(content), actions: actions);
  }
  return AlertDialog(
      title: Text(title), content: Text(content), actions: actions);
}
