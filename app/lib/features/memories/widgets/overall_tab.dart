import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/database/memory_provider.dart';
import 'package:friend_private/backend/preferences.dart';
import 'package:friend_private/backend/schema/plugin.dart';
import 'package:friend_private/core/assets/app_vectors.dart';
import 'package:friend_private/core/theme/app_colors.dart';
import 'package:friend_private/pages/settings/widgets/calendar.dart';
import 'package:friend_private/src/common_widget/expandable_text.dart';
import 'package:friend_private/src/common_widget/list_tile.dart';
import 'package:friend_private/utils/features/calendar.dart';
import 'package:friend_private/utils/other/temp.dart';
import 'package:friend_private/widgets/expandable_text.dart';

import '../../../pages/plugins/page.dart';

class OverallTab extends StatefulWidget {
  final Structured target;

  final dynamic
      pluginsResponse; // Replace `Memory` with the actual data type you have

  const OverallTab({super.key, required this.target, this.pluginsResponse});

  @override
  OverallTabState createState() => OverallTabState();
}

class OverallTabState extends State<OverallTab> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final events = widget.target.events;
    final actionItems = widget.target.actionItems;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),

          /// AI Summary
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.summary,
              height: 18.h,
              width: 18.w,
            ),
            title: Text(
              'AI Summary',
              style: textTheme.titleMedium,
            ),
          ),
          ExpandableText(
            text: widget.target.overview,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 12.h),

          /// Chapters
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.chapter,
              height: 18.h,
              width: 18.w,
            ),
            title: Text('Events', style: textTheme.titleMedium),
          ),

          if (events.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No events found',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            )
          else
            ...events.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var event = entry.value;
              SizedBox(height: 12.h);
              return ListTile(
                  leading: Text(
                    '$index.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  title: Text(
                    event.title,
                    // Replace this with the correct event property if needed
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      ''
                      '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: event.created
                        ? null
                        : () {
                            var calEnabled =
                                SharedPreferencesUtil().calendarEnabled;
                            var calSelected =
                                SharedPreferencesUtil().calendarId.isNotEmpty;
                            if (!calEnabled || !calSelected) {
                              routeToPage(context, const CalendarPage());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(!calEnabled
                                      ? 'Enable calendar integration to add events'
                                      : 'Select a calendar to add events to'),
                                ),
                              );
                              return;
                            }
                            MemoryProvider().setEventCreated(event);
                            setState(() => event.created = true);
                            CalendarUtil().createEvent(
                              event.title,
                              event.startsAt,
                              event.duration,
                              description: event.description,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Event added to calendar'),
                              ),
                            );
                          },
                    icon: Icon(event.created ? Icons.check : Icons.add,
                        color: AppColors.black),
                  ));
            }),
          SizedBox(height: 12.h),

          /// Action Items Section
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.action,
              height: 18.h,
              width: 18.w,
            ),
            title: Text(
              'Action Items',
              style: textTheme.titleMedium,
            ),
          ),
          if (actionItems.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'No action items found',
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            )
          else
            ...actionItems.map((actionItem) {
              return CustomListTile(
                minLeadingWidth: 0.w,
                onTap: () {
                  setState(() {
                    actionItem.completed = !actionItem.completed;
                    MemoryProvider().updateActionItem(actionItem);
                  });
                },
                leading: Container(
                  width: 6.h,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: AppColors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  actionItem
                      .description, // Use the appropriate property of ActionItem
                  style: textTheme.bodyLarge?.copyWith(
                    color: actionItem.completed
                        ? AppColors.greyLight
                        : AppColors.grey,
                    decoration: actionItem.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              );
            }),
          // getPluginsWidgets(
          //   context,
          //   pluginResponse,
          //   pluginsList,
          //   (i) => setState(
          //       () => pluginResponseExpanded[i] = !pluginResponseExpanded[i]),
          // ),
          const SizedBox(height: 32),
          //   Divider(color: AppColors.purpleBright, height: 1),
          const SizedBox(height: 32),

          // ...getPluginsWidgets(
          //   context,
          //   pluginResponse,
          //   pluginsList,
          //   pluginResponseExpanded,
          //   (i) => setState(
          //       () => pluginResponseExpanded[i] = !pluginResponseExpanded[i]),
          // )
        ],
      ),
    );
  }

  List<Widget> getPluginsWidgets(
    BuildContext context,
    List<PluginResponse> pluginResponse,
    List<Plugin> pluginsList,
    List<bool> pluginResponseExpanded,
    Function(int) onItemToggled,
  ) {
    if (pluginResponseExpanded.length != pluginResponse.length) {
      pluginResponseExpanded =
          List.generate(pluginResponse.length, (index) => false);
    }
    print(pluginResponse.isEmpty);
    if (pluginResponse.isEmpty) {
      return [
        const SizedBox(height: 32),
        Text(
          'No plugins were triggered.',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: const Border(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (c) => const PluginsPage()));
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Text('Enable Plugins',
                        style:
                            TextStyle(color: AppColors.black, fontSize: 16))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ];
    } else {
      return [
        Text(
          'Plugins 🧑‍💻',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 24),
        ...pluginResponse.mapIndexed((i, pluginResponse) {
          if (pluginResponse.content.length < 5) return const SizedBox.shrink();
          Plugin? plugin = pluginsList.firstWhereOrNull(
              (element) => element.id == pluginResponse.pluginId);
          return Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                plugin != null
                    ? ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          maxRadius: 16,
                          backgroundImage: NetworkImage(plugin.getImageUrl()),
                        ),
                        title: Text(
                          plugin.name,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            plugin.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: utf8.decode(
                                    pluginResponse.content.trim().codeUnits)));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Plugin response copied to clipboard'),
                            ));
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                // ExpandableTextWidget(
                //   text: utf8.decode(pluginResponse.content.trim().codeUnits),
                //   isExpanded: pluginResponseExpanded[i],
                //   toggleExpand: () {
                //     onItemToggled(i);
                //   },
                //   style: TextStyle(
                //       color: AppColors.blackSecondary,
                //       fontSize: 15,
                //       height: 1.3),
                //   maxLines: 6,
                //   linkColor: Colors.white,
                // ),
                ExpandableTextWidget(
                  text: utf8.decode(pluginResponse.content.trim().codeUnits),
                  // isExpanded: pluginResponseExpanded[i],
                  isExpanded: pluginResponseExpanded[i],
                  toggleExpand: () => onItemToggled(i), // Updates the state
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                    height: 1.3,
                  ),
                  maxLines: 6,
                  linkColor: Colors.white,
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ];
    }
  }
}
