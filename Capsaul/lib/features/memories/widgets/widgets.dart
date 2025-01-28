import 'dart:convert';
import 'dart:developer';

import 'package:capsaul/backend/api_requests/api/other.dart';
import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:capsaul/backend/preferences.dart';
import 'package:capsaul/backend/schema/plugin.dart';
import 'package:capsaul/core/constants/constants.dart';
import 'package:capsaul/core/theme/app_colors.dart';
import 'package:capsaul/features/memories/widgets/confirm_deletion_widget.dart';
import 'package:capsaul/features/memories/widgets/enable_title.dart';
import 'package:capsaul/features/memories/widgets/test_prompts.dart';
import 'package:capsaul/pages/settings/widgets/calendar.dart';
import 'package:capsaul/utils/features/calendar.dart';
import 'package:capsaul/utils/other/temp.dart';
import 'package:capsaul/widgets/dialog.dart';
import 'package:capsaul/widgets/expandable_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:share_plus/share_plus.dart';

List<Widget> getSummaryWidgets(
  BuildContext context,
  Memory memory,
  TextEditingController overviewController,
  bool editingOverview,
  FocusNode focusOverviewField,
  StateSetter setState,
) {
  var structured = memory.structured.target!;
  String time = memory.startedAt == null
      ? dateTimeFormat('h:mm a', memory.createdAt)
      : '${dateTimeFormat('h:mm a', memory.startedAt)} to ${dateTimeFormat('h:mm a', memory.finishedAt)}';
  return [
    const SizedBox(height: 16),
    const Align(
      alignment: Alignment.centerLeft,
      child: Icon(
        Icons.edit,
        color: Colors.grey,
        size: 16,
      ),
    ),
    h8,
    EditableTitle(
      initialText: structured.title,
      onTextChanged: (newTitle) {
        setState(() {
          structured.title = newTitle;

          MemoryProvider().updateMemoryStructured(structured);
        });
      },
      discarded: memory.discarded,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 32),
    ),
    const SizedBox(height: 16),
    Text(
      '${dateTimeFormat('MMM d,  yyyy', memory.createdAt)} ${memory.startedAt == null ? 'at' : 'from'} $time',
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    ),
    const SizedBox(height: 16),
    Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          child: Image.memory(memory.memoryImg!),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              structured.category.isEmpty
                  ? ' ' // Handle the case when the category list is empty
                  : structured.category[0][0].toUpperCase() +
                      structured.category[0].substring(1).toLowerCase(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    ),
    const SizedBox(height: 40),
    memory.discarded
        ? const SizedBox.shrink()
        : Text(
            'Overview',
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
          ),
    memory.discarded
        ? const SizedBox.shrink()
        : ((memory.geolocation.target != null)
            ? const SizedBox(height: 8)
            : const SizedBox.shrink()),
    memory.discarded
        ? const SizedBox.shrink()
        : const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.edit,
              color: Colors.grey,
              size: 16,
            ),
          ),
    memory.discarded
        ? const SizedBox.shrink()
        : _getEditTextField(memory, overviewController, editingOverview,
            focusOverviewField, setState),
    memory.discarded ? const SizedBox.shrink() : const SizedBox(height: 40),
    structured.actionItems.isNotEmpty
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Action Items',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 26),
              ),
              IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text:
                            '- ${structured.actionItems.map((e) => e.description).join('\n- ')}'));
                    avmSnackBar(context, "Action items copied to clipboard");
                    MixpanelManager()
                        .copiedMemoryDetails(memory, source: 'Action Items');
                  },
                  icon: const Icon(Icons.copy_rounded,
                      color: Colors.white, size: 20))
            ],
          )
        : const SizedBox.shrink(),
    ...structured.actionItems.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListTile(
          onTap: () {
            setState(() {
              item.completed = !item.completed;
              MemoryProvider().updateActionItem(item);
            });
          },
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            color: item.completed ? Colors.green : Colors.grey,
            item.completed ? Icons.task_alt : Icons.circle_outlined,
            size: 20,
          ),
          title: Text(
            item.description,
            style: TextStyle(
                color: Colors.grey.shade300, fontSize: 16, height: 1.3),
          ),
        ),
      );
    }),
    structured.actionItems.isNotEmpty
        ? const SizedBox(height: 40)
        : const SizedBox.shrink(),
    structured.events.isNotEmpty
        ? Row(
            children: [
              Icon(Icons.event, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              Text(
                'Events',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 26),
              )
            ],
          )
        : const SizedBox.shrink(),
    ...structured.events.map<Widget>((event) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          event.title,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${dateTimeFormat('MMM d, yyyy', event.startsAt)} at ${dateTimeFormat('h:mm a', event.startsAt)} ~ ${event.duration} minutes.',
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
        trailing: IconButton(
          onPressed: event.created
              ? null
              : () {
                  var calEnabled = SharedPreferencesUtil().calendarEnabled;
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
                  avmSnackBar(context, 'Event added to calendar');
                },
          icon: Icon(event.created ? Icons.check : Icons.add,
              color: Colors.white),
        ),
      );
    }),
    structured.events.isNotEmpty
        ? const SizedBox(height: 40)
        : const SizedBox.shrink(),
  ];
}

_getEditTextField(
  Memory memory,
  TextEditingController controller,
  bool enabled,
  FocusNode focusNode,
  StateSetter setState,
) {
  var structured = memory.structured.target!;
  if (memory.discarded) return const SizedBox.shrink();
  return enabled
      ? TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          focusNode: focusNode,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(0),
          ),
          enabled: enabled,
          style:
              TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.3),
        )
      : SelectionArea(
          child: EditableTitle(
            initialText: controller.text,
            onTextChanged: (changedOverview) {
              setState(() {
                structured.overview = changedOverview;

                MemoryProvider().updateMemoryStructured(structured);
              });
            },
            discarded: enabled,
            style: TextStyle(
                color: Colors.grey.shade300, fontSize: 15, height: 1.3),
          ),
          // child: Text(
          //   controller.text,
          //   style: TextStyle(
          //       color: Colors.grey.shade300, fontSize: 15, height: 1.3),
          // ),
        );
}

List<Widget> getPluginsWidgets(
  BuildContext context,
  Memory memory,
  List<Plugin> pluginsList,
  List<bool> pluginResponseExpanded,
  Function(int) onItemToggled,
) {
  if (memory.pluginsResponse.isEmpty) {
    return [
      const SizedBox(height: 32),
      Text(
        'No plugins were triggered\nfor this memory.',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(127, 208, 208, 208),
                    Color.fromARGB(127, 188, 99, 121),
                    Color.fromARGB(127, 86, 101, 182),
                    Color.fromARGB(127, 126, 190, 236)
                  ],
                ),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MaterialButton(
              onPressed: () {
                // Navigator.of(context).push(
                //     MaterialPageRoute(builder: (c) => const PluginsPage())); ===> CHECK THIS LATER
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Text('Enable Plugins',
                      style: TextStyle(color: Colors.white, fontSize: 16))),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
    ];
  }
  return [
    // include a way to trigger specific plugins
    if (memory.pluginsResponse.isNotEmpty && !memory.discarded) ...[
      memory.structured.target!.actionItems.isEmpty
          ? const SizedBox(height: 40)
          : const SizedBox.shrink(),
      Text(
        'Plugins 🧑‍💻',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 26),
      ),
      const SizedBox(height: 24),
      ...memory.pluginsResponse.mapIndexed((i, pluginResponse) {
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
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          plugin.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
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
                          MixpanelManager().copiedMemoryDetails(memory,
                              source: 'Plugin Response');
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
              ExpandableTextWidget(
                text: utf8.decode(pluginResponse.content.trim().codeUnits),
                isExpanded: pluginResponseExpanded[i],
                toggleExpand: () {
                  if (!pluginResponseExpanded[i]) {
                    MixpanelManager().pluginResultExpanded(
                        memory, pluginResponse.pluginId ?? '');
                  }
                  onItemToggled(i);
                },
                style: TextStyle(
                    color: Colors.grey.shade300, fontSize: 15, height: 1.3),
                maxLines: 6,
                // Change this to 6 if you want the initial max lines to be 6
                linkColor: Colors.white,
              ),
            ],
          ),
        );
      }),
    ],
    const SizedBox(height: 8)
  ];
}

List<Widget> getGeolocationWidgets(Memory memory, BuildContext context) {
  return memory.geolocation.target == null || memory.discarded ? [] : [];
}

void showOptionsBottomSheet(
  BuildContext context,
  StateSetter setState,
  Memory memory,
  Function(BuildContext, StateSetter, Memory, Function) reprocessMemory,
) async {
  bool loadingReprocessMemory = false;
  bool displayDevTools = false;
  // bool displayMemoryPromptField = false;
  bool loadingPluginIntegrationTest = false;
  // TextEditingController controller = TextEditingController();

  var result = await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: displayDevTools
                    ? [
                        ListTile(
                          title:
                              const Text('Trigger Memory Created Integration'),
                          leading: loadingPluginIntegrationTest
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.blue),
                                  ),
                                )
                              : const Icon(Icons.send_to_mobile_outlined),
                          onTap: () async {
                            setModalState(
                                () => loadingPluginIntegrationTest = true);

                            try {
                              final response = await webhookOnMemoryCreatedCall(
                                  memory,
                                  returnRawBody: true);

                              // Check if the widget is still mounted before proceeding
                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                builder: (c) => getDialog(
                                  context,
                                  () => Navigator.pop(context),
                                  () => Navigator.pop(context),
                                  'Result:',
                                  response,
                                  okButtonText: 'Ok',
                                  singleButton: true,
                                ),
                              );
                            } catch (e) {
                              // Handle any errors that occur during the async operation
                              log(e.toString());

                              // Check if the widget is still mounted before showing an error dialog
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (c) => getDialog(
                                    context,
                                    () => Navigator.pop(context),
                                    () => Navigator.pop(context),
                                    'Error:',
                                    'Failed to trigger integration. Please try again.',
                                    okButtonText: 'Ok',
                                    singleButton: true,
                                  ),
                                );
                              }
                            } finally {
                              // Ensure the loading state is reset, even if an error occurs
                              if (context.mounted) {
                                setModalState(
                                    () => loadingPluginIntegrationTest = false);
                              }
                            }
                          },
                        ),
                        ListTile(
                          title: const Text('Test a Memory Prompt'),
                          leading: const Icon(Icons.chat),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 20),
                          onTap: () {
                            routeToPage(
                                context, TestPromptsPage(memory: memory));
                          },
                        ),
                      ]
                    : [
                        ListTile(
                          title: const Text('Share memory'),
                          leading: const Icon(Icons.share),
                          onTap: loadingReprocessMemory
                              ? null
                              : () {
                                  // share loading
                                  MixpanelManager()
                                      .memoryShareButtonClick(memory);
                                  Share.share(
                                      memory.structured.target!.toString());
                                  HapticFeedback.lightImpact();
                                },
                        ),
                        ListTile(
                          title: const Text('Re-summarize'),
                          leading: loadingReprocessMemory
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.blue),
                                  ))
                              : const Icon(
                                  Icons.refresh,
                                ),
                          onTap: loadingReprocessMemory
                              ? null
                              : () => reprocessMemory(
                                      context, setModalState, memory, () {
                                    setModalState(() {
                                      loadingReprocessMemory =
                                          !loadingReprocessMemory;
                                    });
                                  }),
                        ),
                        ListTile(
                          title: const Text('Delete'),
                          leading: const Icon(
                            Icons.delete,
                          ),
                          onTap: loadingReprocessMemory
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        elevation: 0,
                                        insetPadding: EdgeInsets.zero,
                                        backgroundColor: Colors.transparent,
                                        alignment:
                                            const AlignmentDirectional(0.0, 0.0)
                                                .resolve(
                                                    Directionality.of(context)),
                                        child: ConfirmDeletionWidget(
                                            memory: memory,
                                            onDelete: () {
                                              Navigator.pop(context, true);
                                            }),
                                      );
                                    },
                                  );
                                },
                        ),

                        // ListTile(
                        //   title:
                        //       const Text('Trigger Memory Created Integration'),
                        //   leading: loadingPluginIntegrationTest
                        //       ? const SizedBox(
                        //           height: 24,
                        //           width: 24,
                        //           child: CircularProgressIndicator(
                        //             valueColor: AlwaysStoppedAnimation<Color>(
                        //                 AppColors.blue),
                        //           ),
                        //         )
                        //       : const Icon(Icons.send_to_mobile_outlined),
                        //   onTap: () {
                        //     setModalState(
                        //         () => loadingPluginIntegrationTest = true);
                        //     // if not set, show dialog to set URL or take them to settings.

                        //     webhookOnMemoryCreatedCall(memory,
                        //             returnRawBody: true)
                        //         .then((response) {
                        //       showDialog(
                        //         context: context,
                        //         builder: (c) => getDialog(
                        //           context,
                        //           () => Navigator.pop(context),
                        //           () => Navigator.pop(context),
                        //           'Result:',
                        //           response,
                        //           okButtonText: 'Ok',
                        //           singleButton: true,
                        //         ),
                        //       );
                        //       setModalState(
                        //           () => loadingPluginIntegrationTest = false);
                        //     });
                        //   },
                        // ),
                        // ListTile(
                        //   title: const Text('Test a Memory Prompt'),
                        //   leading: const Icon(Icons.chat),
                        //   trailing:
                        //       const Icon(Icons.arrow_forward_ios, size: 20),
                        //   onTap: () {
                        //     routeToPage(
                        //         context, TestPromptsPage(memory: memory));
                        //   },
                        // ),
                        // ListTile(
                        //   title: const Text('Trigger Zap Created Integration'),
                        //   leading: loadingPluginIntegrationTest
                        //       ? const SizedBox(
                        //           height: 24,
                        //           width: 24,
                        //           child: CircularProgressIndicator(
                        //             valueColor: AlwaysStoppedAnimation<Color>(
                        //                 AppColors.blue),
                        //           ),
                        //         )
                        //       : const Icon(
                        //           Icons.send_to_mobile_outlined,
                        //         ),
                        //   onTap: () {
                        //     setModalState(
                        //         () => loadingPluginIntegrationTest = true);
                        //     // if not set, show dialog to set URL or take them to settings.

                        //     zapWebhookOnMemoryCreatedCall(memory,
                        //             returnRawBody: true)
                        //         .then((response) {
                        //       showDialog(
                        //         context: context,
                        //         builder: (c) => getDialog(
                        //           context,
                        //           () => Navigator.pop(context),
                        //           () => Navigator.pop(context),
                        //           'Result:',
                        //           response,
                        //           okButtonText: 'Ok',
                        //           singleButton: true,
                        //         ),
                        //       );
                        //       setModalState(
                        //           () => loadingPluginIntegrationTest = false);
                        //     });
                        //   },
                        // ),
                        SharedPreferencesUtil().devModeEnabled
                            ? ListTile(
                                onTap: () {
                                  setModalState(() {
                                    displayDevTools = !displayDevTools;
                                  });
                                },
                                title: const Text('Developer Tools'),
                                leading: const Icon(
                                  Icons.developer_mode,
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 20),
                              )
                            : const SizedBox.shrink(),
                        h16,
                      ],
              ),
            );
          }));
  if (result == true) setState(() {});
}
