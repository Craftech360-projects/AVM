import 'package:altio/backend/mixpanel.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/wizard/pages/signin_page.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/pages/settings/widgets/about_you.dart';
import 'package:altio/pages/settings/widgets/backup_btn.dart';
import 'package:altio/pages/settings/widgets/change_name_widget.dart';
import 'package:altio/pages/settings/widgets/restore_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.hasDevice});
  static const String name = 'profilePage';
  final bool hasDevice;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: Center(
        child: Text(
          "Profile Settings",
          style: Theme.of(context).textTheme.titleSmall,
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
                if (widget.hasDevice)
                  const Divider(color: AppColors.purpleDark, height: 1),
                if (widget.hasDevice) const BackupButton(),
                if (widget.hasDevice) const RestoreButton(),
                const Divider(color: AppColors.purpleDark, height: 1),
                _buildUserIdTile(),
                _buildDeleteAccountTile(),
                getSignOutButton(context),
              ],
            ),
    );
  }

  ListTile _buildProfileTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'About You',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        'What Altio has learned about you',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.self_improvement,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
      onTap: () {
        widget.hasDevice
            ? Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AboutYouScreen(),
                  // NeuralScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var zoomInAnimation = Tween(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    );

                    return ScaleTransition(
                      scale: zoomInAnimation,
                      child: child,
                    );
                  },
                ),
              )
            : avmSnackBar(context,
                "Altio couldn't find an active device associated with your account! Please connect a device.");
      },
    );
  }

  ListTile _buildNameTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        SharedPreferencesUtil().givenName.isEmpty ? 'Set Name' : 'Change Name',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        SharedPreferencesUtil().givenName.isEmpty
            ? 'Not set'
            : SharedPreferencesUtil().givenName,
        style: Theme.of(context).textTheme.bodySmall,
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
      title: Text(
        'User Id',
        style: Theme.of(context).textTheme.bodyMedium,
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
      title: Text(
        'Delete Account',
        style: Theme.of(context).textTheme.bodyMedium,
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
          },
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      await SharedPreferencesUtil().preferences?.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
        (route) => false,
      );

      setState(() {
        isLoading = false;
      });

      avmSnackBar(context, "Signed out successfully");
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      avmSnackBar(context, "Sign-out failed! Please try again");
    }
  }

  Widget getSignOutButton(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Sign Out',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: CircleAvatar(
        backgroundColor: AppColors.purpleDark,
        child: Icon(
          Icons.logout_rounded,
          size: 22.h,
          color: AppColors.commonPink,
        ),
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomDialogWidget(
              title: "Sign out",
              message: "Are you sure you want to sign out?",
              icon: Icons.logout_rounded,
              yesPressed: _handleSignOut,
            );
          },
        );
      },
    );
  }
}
