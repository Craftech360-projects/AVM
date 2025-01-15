import 'package:capsoul/backend/mixpanel.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/core/widgets/typing_indicator.dart';
import 'package:capsoul/features/wizard/pages/signin_page.dart';
import 'package:capsoul/pages/home/custom_scaffold.dart';
import 'package:capsoul/pages/settings/widgets/backup_btn.dart';
import 'package:capsoul/pages/settings/widgets/change_name_widget.dart';
import 'package:capsoul/pages/settings/widgets/restore_btn.dart';
import 'package:capsoul/widgets/custom_dialog_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String name = 'profilePage';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: const Center(
        child: Text(
          "Profile Settings",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19),
        ),
      ),
      showBackBtn: true,
      showBatteryLevel: false,
      showGearIcon: true,
      body: isLoading
          ? TypingIndicator()
          : ListView(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              children: <Widget>[
                _buildProfileTile(),
                _buildNameTile(),
                h16,
                const Divider(color: AppColors.purpleDark, height: 1),
                h16,
                const BackupButton(),
                h16,
                const RestoreButton(),
                h16,
                const Divider(color: AppColors.purpleDark, height: 1),
                h16,
                _buildUserIdTile(),
                _buildDeleteAccountTile(),
                getSignOutButton(context, _handleSignOut),
              ],
            ),
    );
  }

  ListTile _buildProfileTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        SharedPreferencesUtil().givenName.isEmpty
            ? 'About YOU'
            : 'About ${SharedPreferencesUtil().givenName.toUpperCase()}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text(
        'What Capsoul has learned about you',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.self_improvement,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
    );
  }

  ListTile _buildNameTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        SharedPreferencesUtil().givenName.isEmpty ? 'Set name' : 'Change name',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        SharedPreferencesUtil().givenName.isEmpty
            ? 'Not set'
            : SharedPreferencesUtil().givenName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.person,
          size: 22.h,
          color: AppColors.commonPink,
        ),
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
    );
  }

  ListTile _buildUserIdTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Your User Id',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.copy_rounded,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
      onTap: () {
        MixpanelManager().pageOpened('Authorize Saving Recordings');
        Clipboard.setData(ClipboardData(text: SharedPreferencesUtil().uid));
        avmSnackBar(context, "User ID copied to clipboard");
      },
    );
  }

  ListTile _buildDeleteAccountTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Delete Account',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.red,
        ),
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.warning,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
      onTap: () {
        MixpanelManager().pageOpened('Profile Delete Account Dialog');
        showDialog(
          context: context,
          builder: (ctx) {
            return SizedBox();
            // return getDialog(
            //   context,
            //   () => Navigator.of(context).pop(),
            //   () => launchUrl(Uri.parse('mailto:craftechapps@gmail.com')),
            //   'Deleting Account?',
            //   'Please send us an email at craftechapps@gmail.com',
            //   okButtonText: 'Open Email',
            //   singleButton: false,
            // );
          },
        );
      },
    );
  }

  void _handleSignOut() async {
    try {
      isLoading = true;
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Check if the widget is still mounted before using context
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
        (route) => false,
      );
      isLoading = false;
      avmSnackBar(context, "Signed out");
    } catch (e) {
      debugPrint(e.toString());
      isLoading = false;
      if (!mounted) return;
      avmSnackBar(context, "Sign-out failed! Please try again");
    }
  }

  Widget getSignOutButton(BuildContext context, VoidCallback onSignOut) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Sign Out',
        style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.logout_rounded,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
      onTap: () => customDialogBox(
        context,
        icon: Icons.logout_rounded,
        title: "Sign Out",
        message: "Are you sure you want to sign out?",
        yesPressed: onSignOut,
      ),
    );
  }
}
