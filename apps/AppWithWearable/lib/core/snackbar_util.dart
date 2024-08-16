import 'package:flutter/material.dart';

void showSnackBar({
  required String message,
  required BuildContext context,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: action,
    ),
  );
}
