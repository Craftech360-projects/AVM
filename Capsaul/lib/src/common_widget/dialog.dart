import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> sections;

  const CustomDialog({
    super.key,
    this.title = '',
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: br15),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: br15,
          border: Border.all(),
          color: AppColors.grey.withValues(alpha: 0.1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            const Divider(
              thickness: 2,
              color: AppColors.purpleDark,
            ),
            h8,
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(AppColors.purpleDark),
                ),
                child: Scrollbar(
                  thickness: 3.0,
                  radius: const Radius.circular(10),
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections
                          .map((section) => _buildSection(
                                section['heading'] ?? '',
                                List<String>.from(section['points'] ?? []),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  label: Text(
                    "Close",
                    style: TextStyle(color: AppColors.black),
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.black,
                  ),
                  iconAlignment: IconAlignment.end,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String heading, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        ..._buildPoints(points),
        const SizedBox(height: 20),
      ],
    );
  }

  List<Widget> _buildPoints(List<String> points) {
    return points
        .map(
          (point) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(fontSize: 15, height: 1.2),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
