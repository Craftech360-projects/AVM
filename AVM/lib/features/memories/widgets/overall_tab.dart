import 'dart:convert';

import 'package:avm/backend/database/geolocation.dart';
import 'package:avm/backend/database/memory.dart';
import 'package:avm/backend/database/memory_provider.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/plugin.dart';
import 'package:avm/core/assets/app_vectors.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/settings/widgets/calendar.dart';
import 'package:avm/src/common_widget/expandable_text.dart';
import 'package:avm/src/common_widget/list_tile.dart';
import 'package:avm/utils/features/calendar.dart';
import 'package:avm/utils/other/temp.dart';
import 'package:avm/widgets/expandable_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class OverallTab extends StatefulWidget {
  final Structured target;
  final dynamic pluginsResponse;
  final Geolocation? geolocation;

  const OverallTab(
      {super.key,
      required this.target,
      this.pluginsResponse,
      this.geolocation});

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
          h10,

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
          h20,

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
              padding: EdgeInsets.symmetric(vertical: 0.h),
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
              h10;
              return ListTile(
                  leading: Text(
                    '$index.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  title: Text(
                    event.title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
                      style:
                          const TextStyle(color: AppColors.grey, fontSize: 15),
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
          h20,

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
              padding: EdgeInsets.symmetric(vertical: 0.h),
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
                  actionItem.description,
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
          h30,

          /// Geolocation Section
          // if (widget.geolocation != null &&
          //     widget.geolocation!.latitude != null &&
          //     widget.geolocation!.longitude != null)
          //   GestureDetector(
          //     onTap: () async {
          //       final availableMaps = await MapLauncher.installedMaps;
          //       if (availableMaps.isNotEmpty) {
          //         await availableMaps.first.showMarker(
          //           coords: Coords(widget.geolocation!.latitude!,
          //               widget.geolocation!.longitude!),
          //           title: "Memory Location",
          //         );
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('No map applications available'),
          //           ),
          //         );
          //       }
          //     },
          //     child: Center(
          //       child: Column(
          //         children: [
          //           Image.network(
          //             'https://maps.googleapis.com/maps/api/staticmap?center=${widget.geolocation!.latitude},${widget.geolocation!.longitude}&zoom=14&size=400x200&markers=color:red%7C${widget.geolocation!.latitude},${widget.geolocation!.longitude}&key=YOUR_API_KEY',
          //             fit: BoxFit.cover,
          //             errorBuilder: (context, error, stackTrace) {
          //               return Column(
          //                 mainAxisAlignment: MainAxisAlignment.center,
          //                 children: [
          //                   Icon(Icons.error, color: AppColors.red, size: 50),
          //                   SizedBox(height: 8),
          //                   Text(
          //                     'Failed to load map image',
          //                     style: textTheme.bodyLarge?.copyWith(
          //                       color: AppColors.grey,
          //                     ),
          //                   ),
          //                 ],
          //               );
          //             },
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
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
    if (pluginResponse.isEmpty) {
      return [
        h30,
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
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (c) => const PluginsPage())); ==> CHECK THIS LATER
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
        h30,
      ];
    } else {
      return [
        Text(
          'Plugins 🧑‍💻',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
        ),
        h20,
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
                          backgroundColor: AppColors.white,
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
                                color: AppColors.grey, fontSize: 14),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              color: AppColors.white, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: utf8.decode(
                                    pluginResponse.content.trim().codeUnits)));
                            var calEnabled =
                                SharedPreferencesUtil().calendarEnabled;
                            avmSnackBar(
                                context,
                                !calEnabled
                                    ? 'Enable calendar integration to add events'
                                    : 'Select a calendar to add events to');
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                ExpandableTextWidget(
                  text: utf8.decode(pluginResponse.content.trim().codeUnits),
                  isExpanded: pluginResponseExpanded[i],
                  toggleExpand: () => onItemToggled(i),
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 15,
                    height: 1.3,
                  ),
                  maxLines: 6,
                  linkColor: AppColors.white,
                ),
              ],
            ),
          );
        }),
        h10,
      ];
    }
  }
}
