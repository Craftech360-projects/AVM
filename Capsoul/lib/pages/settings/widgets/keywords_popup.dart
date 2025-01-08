import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class KeywordsDialog extends StatefulWidget {
  const KeywordsDialog({
    super.key,
    required this.initialSelectedKeywords,
  });

  final Set<String> initialSelectedKeywords;

  @override
  KeywordsDialogState createState() => KeywordsDialogState();
}

class KeywordsDialogState extends State<KeywordsDialog> {
  late final Set<String> selectedKeywords;

  final List<String> keywords = [
    'AI',
    'AR VR',
    'Bitcoin',
    'Blockchain',
    'Cryptocurrency',
    'Cybersecurity',
    'Data Science',
    'Quantum Computing',
    'Machine Learning',
    'Internet of Things',
    'Edge Computing',
    '5G',
    'Cloud Computing',
    'Big Data',
  ];

  @override
  void initState() {
    super.initState();
    selectedKeywords = {...widget.initialSelectedKeywords};
    keywords.sort();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: br10,
      ),
      title: const Text(
        'Select Keywords',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: keywords.map((keyword) {
            final isSelected = selectedKeywords.contains(keyword);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedKeywords.remove(keyword);
                  } else {
                    selectedKeywords.add(keyword);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.blue : AppColors.grey,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  borderRadius: br5,
                  color: isSelected
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : AppColors.white,
                ),
                child: Text(
                  keyword,
                  style: TextStyle(
                    color: isSelected ? AppColors.blue : AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(60, 40),
                backgroundColor: AppColors.red,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: br10,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.white,
                size: 17,
              ),
              label: const Text(
                'Discard',
                style: TextStyle(fontSize: 13),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(60, 40),
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: br10,
                ),
              ),
              onPressed: () {
                if (selectedKeywords.isEmpty) {
                  avmSnackBar(context, "Please select at least one item");
                  return;
                }
                Navigator.of(context).pop(selectedKeywords.toList());
              },
              icon: const Icon(
                Icons.check,
                color: AppColors.white,
                size: 17,
              ),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        )
      ],
    );
  }
}
