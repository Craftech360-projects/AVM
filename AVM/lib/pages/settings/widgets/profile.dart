import 'package:avm/backend/auth.dart';
import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/features/wizard/pages/signin_page.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/pages/settings/widgets/backup_btn.dart';
import 'package:avm/pages/settings/widgets/change_name_widget.dart';
import 'package:avm/pages/settings/widgets/restore_btn.dart';
import 'package:avm/widgets/custom_dialog_box.dart';
import 'package:avm/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String name = 'profilePage';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: const Center(
        child: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      showBackBtn: true,
      showBatteryLevel: false,
      showGearIcon: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
        child: ListView(
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: Text(
                  SharedPreferencesUtil().givenName.isEmpty
                      ? 'About YOU'
                      : 'About ${SharedPreferencesUtil().givenName.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('What AVM has learned about you',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: CircleAvatar(
                backgroundColor: AppColors.greyLavender,
                child: Icon(Icons.self_improvement, size: 22.h),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: Text(
                SharedPreferencesUtil().givenName.isEmpty
                    ? 'Set Your Name'
                    : 'Change Your Name',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                SharedPreferencesUtil().givenName.isEmpty
                    ? 'Not set'
                    : SharedPreferencesUtil().givenName,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: CircleAvatar(
                backgroundColor: AppColors.greyLavender,
                child: Icon(Icons.person, size: 22.h),
              ),
              onTap: () async {
                MixpanelManager().pageOpened('Profile Change Name');
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ChangeNameWidget();
                  },
                ).whenComplete(() => setState(() {}));
              },
            ),
            h20,
            const Divider(color: AppColors.purpleBright, height: 1),
            h15,
            const BackupButton(),
            h15,
            const RestoreButton(),
            h20,
            const Divider(color: AppColors.purpleBright, height: 1),
            h20,
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: const Text('Your User Id',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              // subtitle: Text(SharedPreferencesUtil().uid),
              trailing: CircleAvatar(
                backgroundColor: AppColors.greyLavender,
                child: Icon(Icons.copy_rounded, size: 22.h),
              ),
              onTap: () {
                MixpanelManager().pageOpened('Authorize Saving Recordings');
                Clipboard.setData(
                    ClipboardData(text: SharedPreferencesUtil().uid));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('UID copied to clipboard')));
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
              title: const Text('Delete Account',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.red)),
              trailing: CircleAvatar(
                backgroundColor: AppColors.greyLavender,
                child: Icon(Icons.warning, size: 22.h),
              ),
              onTap: () {
                MixpanelManager().pageOpened('Profile Delete Account Dialog');
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return getDialog(
                        context,
                        () => Navigator.of(context).pop(),
                        () => launchUrl(
                            Uri.parse('mailto:craftechapps@gmail.com')),
                        'Deleting Account?',
                        'Please send us an email at craftechapps@gmail.com',
                        okButtonText: 'Open Email',
                        singleButton: false,
                      );
                    });
              },
            ),
            getSignOutButton(context, () {
              signOut(context);
              SharedPreferencesUtil().onboardingCompleted = false;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SigninPage(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

Widget getSignOutButton(BuildContext context, VoidCallback onSignOut) {
  return ListTile(
    contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
    title: const Text(
      'Sign Out',
      style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
    ),
    trailing: CircleAvatar(
      backgroundColor: AppColors.greyLavender,
      child: Icon(Icons.logout_rounded, size: 22.h),
    ),
    onTap: () => customDialogBox(
      context,
      icon: Icons.logout_rounded,
      title: "Sign Out",
      message: "Are you sure you want to sign out?",
      yesPressed: () {},
    ),
  );
}
