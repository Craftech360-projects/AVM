import 'package:capsoul/backend/auth.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/widgets/custom_dialog_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangeNameWidget extends StatefulWidget {
  const ChangeNameWidget({super.key});

  @override
  State<ChangeNameWidget> createState() => _ChangeNameWidgetState();
}

class _ChangeNameWidgetState extends State<ChangeNameWidget> {
  late TextEditingController nameController;
  User? user;
  bool isSaving = false;

  @override
  void initState() {
    user = getFirebaseUser();
    nameController = TextEditingController(text: user?.displayName ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialogWidget(
      title: "Change Your Name?",
      message: "How AVM should call you?",
      icon: Icons.sentiment_satisfied_alt_rounded,
      showTextField: true,
      noText: "Cancel",
      yesText: "Save",
      yesPressed: () {
        if (nameController.text.isEmpty || nameController.text.trim().isEmpty) {
          avmSnackBar(context, "Name cannot be empty");
          return;
        }
        SharedPreferencesUtil().givenName = nameController.text;
        updateGivenName(nameController.text);
        avmSnackBar(context, "Name updated successfully!");
        Navigator.of(context).pop();
      },
    );
  }
}
