import 'dart:convert';

import 'package:altio/backend/database/geolocation.dart';
import 'package:altio/backend/database/memory.dart';
import 'package:altio/backend/database/memory_provider.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/plugin.dart';
import 'package:altio/core/assets/app_vectors.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/features/chat/bloc/chat_bloc.dart';
import 'package:altio/features/chat/presentation/chat_screen.dart';
import 'package:altio/pages/settings/widgets/calendar.dart';
import 'package:altio/src/common_widget/expandable_text.dart';
import 'package:altio/src/common_widget/list_tile.dart';
import 'package:altio/utils/features/calendar.dart';
import 'package:altio/utils/other/temp.dart';
import 'package:altio/widgets/expandable_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';

class OverallTab extends StatefulWidget {
  final Structured target;
  final dynamic pluginsResponse;
  final Geolocation? geolocation;

  const OverallTab({
    super.key,
    required this.target,
    this.pluginsResponse,
    this.geolocation,
  });

  @override
  OverallTabState createState() => OverallTabState();
}

class OverallTabState extends State<OverallTab> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final events = widget.target.events;
    final actionItems = widget.target.actionItems;
    final brainstormQns = widget.target.brainstormingQuestions;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h8,

          /// AI Summary
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.summary,
              height: 14.h,
              width: 14.w,
            ),
            title: Text(
              'AI Summary',
              style: textTheme.titleMedium,
            ),
          ),
          ExpandableText(
            text: widget.target.overview,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
          ),
          h16,

          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.qnMark,
              height: 15.h,
              width: 15.w,
            ),
            title:
                Text('Brainstorm with Altio AI', style: textTheme.titleMedium),
          ),
          if (brainstormQns.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: Text(
                'Uhuh! Seems like no questions are available',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            )
          else
            ...brainstormQns.map((question) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.purpleDark,
                    borderRadius: br5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      w8,
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 500),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ChatScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var fadeInAnimation =
                                    Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                      parent: animation, curve: Curves.easeOut),
                                );

                                return FadeTransition(
                                  opacity: fadeInAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                          BlocProvider.of<ChatBloc>(context).add(
                            SendMessage(
                              question,
                              memoryContext: widget.target.title,
                            ),
                          );
                        },
                        child: Icon(
                          opticalSize: 0.1,
                          fill: 0.1,
                          grade: 0.1,
                          weight: 0.1,
                          size: 28,
                          Icons.arrow_circle_right_outlined,
                          color: AppColors.white,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          h16,

          /// Chapters
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.chapter,
              height: 16.h,
              width: 16.w,
            ),
            title: Text('Events', style: textTheme.titleMedium),
          ),
          if (events.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.h),
              child: Text(
                'No events found',
                style: textTheme.bodyMedium?.copyWith(
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
                    style: textTheme.bodyMedium?.copyWith(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: textTheme.bodyMedium?.copyWith(
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
                    icon: Icon(
                      event.created ? Icons.check : Icons.add,
                    ),
                  ),
                ],
              );
            }),
          h16,

          /// Action Items Section
          CustomListTile(
            leading: SvgPicture.asset(
              AppVectors.action,
              height: 15.h,
              width: 15.w,
            ),
            title: Text(
              'Action Items',
              style: textTheme.titleMedium,
            ),
          ),
          if (actionItems.isEmpty)
            Text(
              'No action items found',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            )
          else
            ...actionItems.map((actionItem) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Checkbox(
                        visualDensity:
                            VisualDensity(horizontal: -4, vertical: -4.0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: actionItem.completed,
                        onChanged: (bool? value) {
                          setState(() {
                            actionItem.completed = value ?? false;
                            MemoryProvider().updateActionItem(actionItem);
                          });
                        },
                        activeColor: AppColors.black,
                        side: BorderSide(width: 1, color: AppColors.black),
                      ),
                    ),
                    w4,
                    Expanded(
                      child: Text(
                        actionItem.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: actionItem.completed
                              ? AppColors.black
                              : AppColors.grey,
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
                border: Border.all(color: AppColors.black), borderRadius: br2),
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.geolocation != null &&
                    widget.geolocation!.address != null)
                  Text(
                    'Location 📍',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Divider(
                  color: AppColors.black,
                  thickness: 1,
                ),
                Text(
                  widget.geolocation?.address ?? "No address found!",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
                h8,
                if (widget.geolocation != null &&
                    widget.geolocation!.latitude != null &&
                    widget.geolocation!.longitude != null)
                  GestureDetector(
                    onTap: () => _showImagePopup(context),
                    child: ClipRRect(
                      borderRadius: br12,
                      child: Image.network(
                        'https://maps.googleapis.com/maps/api/staticmap?center=${widget.geolocation!.latitude},${widget.geolocation!.longitude}&zoom=14&size=400x200&markers=color:red%7C${widget.geolocation!.latitude},${widget.geolocation!.longitude}&key=AIzaSyDWJIATVb9XFFr4qgaKpoEFBXIbxMYa250',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, size: 50),
                              h8,
                              Text(
                                'Failed to load map image',
                                style: textTheme.bodyMedium?.copyWith(),
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

  void _showImagePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: br12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _openMapApplication,
                  child: ClipRRect(
                    borderRadius: br5,
                    child: Image.network(
                      width: double.infinity,
                      height: double.infinity,
                      'https://maps.googleapis.com/maps/api/staticmap?center=${widget.geolocation!.latitude},${widget.geolocation!.longitude}&zoom=14&size=400x800&markers=color:red%7C${widget.geolocation!.latitude},${widget.geolocation!.longitude}&key=AIzaSyDWJIATVb9XFFr4qgaKpoEFBXIbxMYa250',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 50),
                            h8,
                            Text(
                              'Failed to load map image',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    alignment: Alignment.center,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openMapApplication() async {
    if (widget.geolocation != null &&
        widget.geolocation!.latitude != null &&
        widget.geolocation!.longitude != null) {
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          coords: Coords(
              widget.geolocation!.latitude!, widget.geolocation!.longitude!),
          title: "Memory Location",
        );
      } else {
        if (!mounted) return;
        avmSnackBar(
            context, "No application was found to open map in your device!");
      }
    }
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
                    child:
                        Text('Enable Plugins', style: TextStyle(fontSize: 16))),
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
