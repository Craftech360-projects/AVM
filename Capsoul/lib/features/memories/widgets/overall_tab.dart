import 'dart:convert';

import 'package:capsoul/backend/database/geolocation.dart';
import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/backend/database/memory_provider.dart';
import 'package:capsoul/backend/preferences.dart';
import 'package:capsoul/backend/schema/plugin.dart';
import 'package:capsoul/core/assets/app_vectors.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/pages/settings/widgets/calendar.dart';
import 'package:capsoul/src/common_widget/expandable_text.dart';
import 'package:capsoul/src/common_widget/list_tile.dart';
import 'package:capsoul/utils/features/calendar.dart';
import 'package:capsoul/utils/other/temp.dart';
import 'package:capsoul/widgets/expandable_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';

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
          h8,

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
          h16,

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
              h8;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
                              style: const TextStyle(
                                  color: AppColors.grey, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: event.created
                        ? null
                        : () {
                            var calEnabled =
                                SharedPreferencesUtil().calendarEnabled;
                            var calSelected =
                                SharedPreferencesUtil().calendarId.isNotEmpty;
                            if (!calEnabled || !calSelected) {
                              routeToPage(context, const CalendarPage());
                              avmSnackBar(
                                  context,
                                  !calEnabled
                                      ? "Enable calendar integration to add events"
                                      : "Select a calendar to add events to");
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
                            avmSnackBar(context, "Event added to calendar");
                          },
                    icon: Icon(event.created ? Icons.check : Icons.add,
                        color: AppColors.black),
                  ),
                ],
              );
            }),
          h16,

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
              return GestureDetector(
                onTap: () {
                  setState(() {
                    actionItem.completed = !actionItem.completed;
                    MemoryProvider().updateActionItem(actionItem);
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
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
                    ),
                  ],
                ),
              );
            }),
          h8,

          Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey), borderRadius: br8),
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.symmetric(vertical: 06, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.geolocation != null &&
                    widget.geolocation!.address != null)
                  Text(
                    'Location 📍',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Divider(
                  color: AppColors.purpleDark,
                  thickness: 1,
                ),
                Text(
                  widget.geolocation?.address ?? "No address found!",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                h8,
                if (widget.geolocation != null &&
                    widget.geolocation!.latitude != null &&
                    widget.geolocation!.longitude != null)
                  GestureDetector(
                    onTap: () async {
                      final availableMaps = await MapLauncher.installedMaps;
                      if (availableMaps.isNotEmpty) {
                        await availableMaps.first.showMarker(
                          coords: Coords(widget.geolocation!.latitude!,
                              widget.geolocation!.longitude!),
                          title: "Memory Location",
                        );
                      } else {
                        avmSnackBar(context,
                            "No application was found to open map in your device!");
                      }
                    },
                    child: ClipRRect(
                      borderRadius: br12,
                      child: Image.network(
                        'https://maps.googleapis.com/maps/api/staticmap?center=${widget.geolocation!.latitude},${widget.geolocation!.longitude}&zoom=14&size=400x200&markers=color:red%7C${widget.geolocation!.latitude},${widget.geolocation!.longitude}&key=AIzaSyDWJIATVb9XFFr4qgaKpoEFBXIbxMYa250',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error,
                                  color: AppColors.black, size: 50),
                              h8,
                              Text(
                                'Failed to load map image',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
        h32,
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
        h32,
      ];
    } else {
      return [
        Text(
          'Plugins 🧑‍💻',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
        ),
        h16,
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
        h8,
      ];
    }
  }
}
