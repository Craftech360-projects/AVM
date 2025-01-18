import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/pages/home/custom_scaffold.dart';
import 'package:flutter/material.dart';

class TACandPP extends StatelessWidget {
  const TACandPP({super.key, required this.onAccept});
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      showAppBar: false,
      body: Container(
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: br15,
            color: Colors.transparent),
        margin: EdgeInsets.symmetric(vertical: 80, horizontal: 12),
        padding: EdgeInsets.all(08),
        child: Column(
          children: [
            Text(
              "Please accept the terms and conditions to continue with Capsaul",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Divider(
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
                  radius: Radius.circular(10),
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'General Terms',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._buildPoints([
                          'You must be at least 18 years old to use this app.',
                          'The app is provided as-is without any warranties.',
                          'We reserve the right to update the terms at any time.',
                        ]),
                        h16,
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._buildPoints([
                          'Your data will be stored securely.',
                          'We do not share your personal information with third parties.',
                          'You can request data deletion at any time.',
                        ]),
                        h16,
                        Text(
                          'User Responsibilities',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ..._buildPoints([
                          'Do not misuse the app for illegal activities.',
                          'Respect other users of the platform.',
                          'Report issues or bugs responsibly.',
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            h16,
            ElevatedButton(
              onPressed: onAccept,
              // onPressed: _onSaveButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleDark,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: br5),
              ),
              child: const Text(
                'Accept Terms',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
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
                Text(
                  '• ',
                  style: TextStyle(fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
