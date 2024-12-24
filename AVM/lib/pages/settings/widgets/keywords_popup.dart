import 'package:flutter/material.dart';

class KeywordsDialog extends StatefulWidget {
  const KeywordsDialog({super.key});

  @override
  KeywordsDialogState createState() => KeywordsDialogState();
}

class KeywordsDialogState extends State<KeywordsDialog> {
  final List<String> keywords = ["bitcoin", "programming", "android", "ios", "AI"];
  final Set<String> selectedKeywords = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Keywords'),
      content: SingleChildScrollView(
        child: ListBody(
          children: keywords.map((keyword) {
            return CheckboxListTile(
              title: Text(keyword),
              value: selectedKeywords.contains(keyword),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedKeywords.add(keyword);
                  } else {
                    selectedKeywords.remove(keyword);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Discard'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}