import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/utils.dart';
import 'package:friend_private/src/core/constant/constant.dart';

getNotificationsWidgets(
  StateSetter setState,
  bool postMemoryNotificationIsChecked,
  bool reconnectNotificationIsChecked,
) {
  return [
    const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'NOTIFICATIONS',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.start,
      ),
    ),
    InkWell(
      onTap: () {
        setState(() {
          if (postMemoryNotificationIsChecked) {
            postMemoryNotificationIsChecked = false;
            SharedPreferencesUtil().postMemoryNotificationIsChecked = false;
          } else {
            postMemoryNotificationIsChecked = true;
            SharedPreferencesUtil().postMemoryNotificationIsChecked = true;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 8.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Post memory analysis',
              style: TextStyle(
                  color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
            ),
            Container(
              decoration: BoxDecoration(
                color: postMemoryNotificationIsChecked
                    ? const Color.fromARGB(255, 150, 150, 150)
                    : Colors.transparent, // Fill color when checked
                border: Border.all(
                  color: const Color.fromARGB(255, 150, 150, 150),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 22,
              height: 22,
              child:
                  postMemoryNotificationIsChecked // Show the icon only when checked
                      ? const Icon(
                          Icons.check,
                          color: Colors.white, // Tick color
                          size: 18,
                        )
                      : null, // No icon when unchecked
            ),
          ],
        ),
      ),
    ),
    InkWell(
      onTap: () {
        setState(() {
          if (reconnectNotificationIsChecked) {
            reconnectNotificationIsChecked = false;
            SharedPreferencesUtil().reconnectNotificationIsChecked = false;
          } else {
            reconnectNotificationIsChecked = true;
            SharedPreferencesUtil().reconnectNotificationIsChecked = true;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8.0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reminder to reconnect',
              style: TextStyle(
                  color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
            ),
            Container(
              decoration: BoxDecoration(
                color: reconnectNotificationIsChecked
                    ? const Color.fromARGB(255, 150, 150, 150)
                    : Colors.transparent, // Fill color when checked
                border: Border.all(
                  color: const Color.fromARGB(255, 150, 150, 150),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              width: 22,
              height: 22,
              child:
                  reconnectNotificationIsChecked // Show the icon only when checked
                      ? const Icon(
                          Icons.check,
                          color: Colors.white, // Tick color
                          size: 18,
                        )
                      : null, // No icon when unchecked
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 32)
  ];
}

getRecordingSettings(
    Function(String?) onLanguageChanged, String selectedLanguage) {
  return [
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'RECORDING SETTINGS',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    ),
    const SizedBox(height: 12),
    Center(
        child: Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.only(left: 16, right: 12, top: 8, bottom: 10),
      child: DropdownButton<String>(
        menuMaxHeight: 350,
        value: selectedLanguage,
        onChanged: onLanguageChanged,
        dropdownColor: Colors.black,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        underline: Container(
          height: 0,
          color: Colors.white,
        ),
        isExpanded: true,
        itemHeight: 48,
        items:
            availableLanguages.keys.map<DropdownMenuItem<String>>((String key) {
          return DropdownMenuItem<String>(
            value: availableLanguages[key],
            child: Text(
              '$key (${availableLanguages[key]})',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
          );
        }).toList(),
      ),
    )),
    const SizedBox(height: 32.0),
  ];
}

getPreferencesWidgets({
  required VoidCallback onOptInAnalytics,
  required VoidCallback viewPrivacyDetails,
  required bool optInAnalytics,
  required VoidCallback onDevModeClicked,
  required bool devModeEnabled,
  required VoidCallback onBackupsClicked,
  required bool backupsEnabled,
}) {
  return [
    const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'PREFERENCES',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.start,
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: InkWell(
        onTap: onOptInAnalytics,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: viewPrivacyDetails,
                  child: const Text(
                    'Help improve AVM by sharing anonymized analytics data',
                    style: TextStyle(
                        color: Color.fromARGB(255, 150, 150, 150),
                        fontSize: 16,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                decoration: BoxDecoration(
                  color: optInAnalytics
                      ? const Color.fromARGB(255, 150, 150, 150)
                      : Colors.transparent, // Fill color when checked
                  border: Border.all(
                    color: const Color.fromARGB(255, 150, 150, 150),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 22,
                height: 22,
                child: optInAnalytics // Show the icon only when checked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white, // Tick color
                        size: 18,
                      )
                    : null, // No icon when unchecked
              ),
            ],
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: InkWell(
        onTap: onBackupsClicked,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Automatic Cloud Backups',
                style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
              ),
              Container(
                decoration: BoxDecoration(
                  color: backupsEnabled
                      ? const Color.fromARGB(255, 150, 150, 150)
                      : Colors.transparent, // Fill color when checked
                  border: Border.all(
                    color: const Color.fromARGB(255, 150, 150, 150),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 22,
                height: 22,
                child: backupsEnabled // Show the icon only when checked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white, // Tick color
                        size: 18,
                      )
                    : null, // No icon when unchecked
              ),
            ],
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: InkWell(
        onTap: onDevModeClicked,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Developer Mode',
                style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150), fontSize: 16),
              ),
              Container(
                decoration: BoxDecoration(
                  color: devModeEnabled
                      ? const Color.fromARGB(255, 150, 150, 150)
                      : Colors.transparent, // Fill color when checked
                  border: Border.all(
                    color: const Color.fromARGB(255, 150, 150, 150),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 22,
                height: 22,
                child: devModeEnabled // Show the icon only when checked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white, // Tick color
                        size: 18,
                      )
                    : null, // No icon when unchecked
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}

getItemAddOn(String title, VoidCallback onTap,
    {required IconData icon, bool visibility = true}) {
  // return Visibility(
  //   visible: visibility,
  //   child: GestureDetector(
  //     onTap: onTap,
  //     child: Padding(
  //       padding: const EdgeInsets.fromLTRB(0, 12, 8, 0),
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: const Color.fromARGB(
  //               0, 255, 255, 255), // Replace with your desired color
  //           borderRadius: BorderRadius.circular(
  //               10.0), // Adjust for desired rounded corners
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           child: Row(
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(
  //                     color: CustomColors.blackPrimary, fontSize: 16),
  //               ),
  //               const SizedBox(width: 16),
  //               Icon(icon, color: CustomColors.grey, size: 16.h),
  //               const Spacer(),
  //               const Icon(
  //                 Icons.arrow_forward_ios,
  //                 color: CustomColors.grey,
  //                 size: 16,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   ),
  // );

  return Visibility(
    visible: visibility,
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 8, 0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                0, 255, 255, 255), // Replace with your desired color
            borderRadius: BorderRadius.circular(
                10.0), // Adjust for desired rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Container(
                //   width: 32, // Circle size
                //   height: 32,
                //   decoration: BoxDecoration(
                //     color: CustomColors.greyLavender, // Background color
                //     shape: BoxShape.circle,
                //   ),
                //   child: Center(
                //     child: Icon(icon, color: CustomColors.grey, size: 16),
                //   ),
                // ),
                // const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      color: CustomColors.blackPrimary, fontSize: 16),
                ),
                const Spacer(),
                // Circular background for the first icon
                // Spacing between icons
                // Circular background for the arrow icon
                Container(
                  width: 32, // Circle size
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        0, 238, 228, 255), // Background color
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: CustomColors.grey,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
