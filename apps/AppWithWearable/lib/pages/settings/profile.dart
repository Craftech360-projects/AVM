import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/auth.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/pages/home/backgrund_scafold.dart';
import 'package:friend_private/pages/onboarding/wrapper.dart';
import 'package:friend_private/pages/settings/BackupButton.dart';
import 'package:friend_private/pages/settings/RestoreButton.dart';
import 'package:friend_private/pages/settings/widgets/change_name_widget.dart';
import 'package:friend_private/src/core/constant/constant.dart';
import 'package:friend_private/src/features/settings/presentation/pages/setting_page.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/dialog.dart';
import 'package:go_router/go_router.dart';
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
    final textTheme = Theme.of(context).textTheme;
    return CustomScaffold(
      backgroundColor: const Color(0xFFE6F5FA),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 20.h,
          ),
        ),
        backgroundColor: const Color(0xFFE6F5FA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context
                .pushNamed(SettingPage.name); // Go back to the previous screen
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              MixpanelManager().pageOpened('SignOut');
              await showDialog(
                context: context,
                builder: (ctx) {
                  return getDialog(context, () {
                    Navigator.of(context).pop();
                  }, () {
                    signOut(context);
                    Navigator.of(context).pop();
                    routeToPage(context, const OnboardingWrapper(),
                        replace: true);
                  }, "Sign Out?", "Are you sure you want to sign out?");
                },
              );
            },

            icon: CircleAvatar(
              backgroundColor: CustomColors.greyLavender,
              child: Icon(Icons.logout, size: 22.h),
            ),
            //const Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        color:
            const Color(0xFFE6F5FA), // Set your desired background color here
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
          child: ListView(
            children: <Widget>[
              // getItemAddOn('Identifying Others', () {
              //   routeToPage(context, const UserPeoplePage());
              // }, icon: Icons.people),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
                title: Text(
                    SharedPreferencesUtil().givenName.isEmpty
                        ? 'About YOU'
                        : 'About ${SharedPreferencesUtil().givenName.toUpperCase()}',
                    style: const TextStyle(color: CustomColors.blackPrimary)),
                subtitle: const Text('What AVM has learned about you 👀'),
                trailing:
                    //  Icon(Icons.self_improvement,
                    //     size: 22.h, color: CustomColors.purpleBright),
                    CircleAvatar(
                  backgroundColor: CustomColors.greyLavender,
                  child: Icon(Icons.self_improvement, size: 22.h),
                ),
              ),

              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
                title: Text(
                  SharedPreferencesUtil().givenName.isEmpty
                      ? 'Set Your Name'
                      : 'Change Your Name',
                  style: const TextStyle(color: CustomColors.blackPrimary),
                ),
                subtitle: Text(SharedPreferencesUtil().givenName.isEmpty
                    ? 'Not set'
                    : SharedPreferencesUtil().givenName),
                trailing: CircleAvatar(
                  backgroundColor: CustomColors.greyLavender,
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

              const SizedBox(height: 24),
              Divider(color: CustomColors.purpleBright, height: 1),
              const SizedBox(height: 16),
              const BackupButton(),
              const SizedBox(height: 16),
              const RestoreButton(),

              const SizedBox(height: 24),
              Divider(color: CustomColors.purpleBright, height: 1),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
                title: const Text('Delete Account',
                    style: TextStyle(color: CustomColors.blackPrimary)),
                trailing: CircleAvatar(
                  backgroundColor: CustomColors.greyLavender,
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
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4, 0, 24, 0),
                title: const Text('Your User Id',
                    style: TextStyle(color: CustomColors.blackPrimary)),
                subtitle: Text(SharedPreferencesUtil().uid),
                trailing: CircleAvatar(
                  backgroundColor: CustomColors.greyLavender,
                  child: Icon(Icons.copy_rounded, size: 22.h),
                ),
                // const Icon(Icons.copy_rounded,
                //     size: 20, color: CustomColors.blackPrimary),
                onTap: () {
                  MixpanelManager().pageOpened('Authorize Saving Recordings');
                  Clipboard.setData(
                      ClipboardData(text: SharedPreferencesUtil().uid));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UID copied to clipboard')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
