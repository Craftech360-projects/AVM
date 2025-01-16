import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/utils/features/backups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestoreButton extends StatefulWidget {
  const RestoreButton({super.key});

  @override
  RestoreButtonState createState() => RestoreButtonState();
}

class RestoreButtonState extends State<RestoreButton> {
  bool isRestoreInProgress = false;

  Future<void> _handleRestore() async {
    if (isRestoreInProgress) return;

    setState(() {
      isRestoreInProgress = true;
    });

    try {
      final success = await retrieveBackup(SharedPreferencesUtil().uid);

      if (mounted) {
        setState(() {
          isRestoreInProgress = false;
        });

        avmSnackBar(
            context,
            success
                ? 'Backup restored successfully!'
                : 'Failed to restore backup');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isRestoreInProgress = false;
        });
        avmSnackBar(context, 'Error occurred while restoring backup');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Restore Latest Backup',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: isRestoreInProgress
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: AppColors.greyLavender,
                  child: Icon(Icons.restore, size: 22.h),
                ),
          // const Icon(
          //     Icons.restore,
          //     size: 22.h,
          //   ),
          onTap: isRestoreInProgress ? null : _handleRestore,
        ),
        if (isRestoreInProgress)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Restoring backup...',
                style: TextStyle(
                    color: AppColors.grey, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}
