import 'dart:developer';

import 'package:altio/backend/database/memory.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/core/widgets/custom_dialog_box.dart';
import 'package:altio/core/widgets/typing_indicator.dart';
import 'package:altio/features/memories/bloc/memory_bloc.dart';
import 'package:altio/features/memories/pages/memory_detail_page.dart';
import 'package:altio/features/memories/widgets/empty_memories.dart';
import 'package:altio/features/memories/widgets/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemoryCardWidget extends StatelessWidget {
  MemoryCardWidget({super.key, required this.memoryBloc});

  final MemoryBloc memoryBloc;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryBloc, MemoryState>(
        bloc: memoryBloc,
        builder: (context, state) {
          if (state.memories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: EmptyMemoriesWidget(),
              ),
            );
          }

          bool isAnyMemorySelected = state.selectedMemories.contains(true);

          return _isLoading
              ? Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      h8,
                      Text("Deleting Memories"),
                      h8,
                      TypingIndicator(),
                    ],
                  ),
                )
              : Column(children: [
                  if (isAnyMemorySelected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialogWidget(
                                    title: "Delete memories",
                                    message:
                                        "Are you sure you want to delete the selected memories? This action cannot be reversed!",
                                    icon: Icons.delete,
                                    noText: "Cancel",
                                    yesText: "Delete",
                                    yesPressed: () {
                                      try {
                                        _isLoading = true;
                                        memoryBloc.add(BatchDeleteMemory());
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        log(e.toString());
                                        avmSnackBar(context,
                                            "Something went wrong! Please try again later");
                                        _isLoading = false;
                                      }
                                    });
                              });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: AppColors.red,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.red),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: Column(
                      children: List.generate(
                        state.memories.length,
                        (index) {
                          Memory memory = state.memories[index];
                          bool isSelected = state.selectedMemories[index];

                          return GestureDetector(
                            onLongPress: () {
                              List<bool> updatedSelection =
                                  List.from(state.selectedMemories);
                              // updatedSelection[index] = !updatedSelection[index];
                              updatedSelection[index] = !isSelected;
                              memoryBloc
                                  .add(UpdatedSelection(updatedSelection));
                              log('Memory at index $index selected: ${updatedSelection[index]}');
                            },
                            child: Dismissible(
                              key: UniqueKey(),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: EdgeInsets.only(right: 30),
                                padding: EdgeInsets.symmetric(
                                    vertical: 04, horizontal: 04),
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.delete,
                                  size: 38,
                                  color: AppColors.red.withValues(alpha: 0.7),
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogWidget(
                                        title: "Delete this memory",
                                        message:
                                            "Are you sure you want to delete this memory? This action cannot be reversed!",
                                        icon: Icons.delete,
                                        noText: "Cancel",
                                        yesText: "Delete",
                                        yesPressed: () {
                                          memoryBloc.add(
                                              DeletedMemory(memory: memory));
                                          Navigator.of(context).pop();
                                        });
                                  },
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    List<bool> updatedSelection =
                                        List.from(state.selectedMemories);
                                    updatedSelection[index] = false;
                                    memoryBloc.add(
                                        UpdatedSelection(updatedSelection));
                                  } else {
                                    memoryBloc.add(
                                        MemoryIndexChanged(memoryIndex: index));
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration:
                                            Duration(milliseconds: 500),
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            MemoryDetailPage(
                                          memoryBloc: memoryBloc,
                                          memoryAtIndex: index,
                                        ),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var fadeInAnimation =
                                              Tween(begin: 0.0, end: 1.0)
                                                  .animate(
                                            CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOut),
                                          );

                                          return FadeTransition(
                                            opacity: fadeInAnimation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: MemoryCard(
                                  memory: memory,
                                  isSelected: isSelected,
                                  onSelect: () {
                                    List<bool> updatedSelection =
                                        List.from(state.selectedMemories);
                                    updatedSelection[index] = !isSelected;
                                    memoryBloc.add(
                                        UpdatedSelection(updatedSelection));
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]);
        });
  }
}
