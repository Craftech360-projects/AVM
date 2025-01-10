import 'dart:developer';

import 'package:capsoul/backend/database/memory.dart';
import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
import 'package:capsoul/core/widgets/custom_dialog_box.dart';
import 'package:capsoul/core/widgets/typing_indicator.dart';
import 'package:capsoul/features/memories/bloc/memory_bloc.dart';
import 'package:capsoul/features/memories/pages/memory_detail_page.dart';
import 'package:capsoul/features/memories/widgets/empty_memories.dart';
import 'package:capsoul/features/memories/widgets/memory_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemoryCardWidget extends StatelessWidget {
  MemoryCardWidget({
    super.key,
    required this.memoryBloc,
  });

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
              padding: EdgeInsets.only(top: 38.0),
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
            : Column(
                children: [
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
                                        "Are you sure you want to delete the selected memories",
                                    icon: Icons.delete_rounded,
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
                          Icons.delete_rounded,
                          color: AppColors.red,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: AppColors.red),
                        ),
                      ),
                    ),
                  Column(
                    children: List.generate(
                      state.memories.length,
                      (index) {
                        // if (index >= state.selectedMemories.length) {
                        //   state.selectedMemories.add(false);
                        // }

                        Memory memory = state.memories[index];
                        bool isSelected = state.selectedMemories[index];

                        return GestureDetector(
                          onLongPress: () {
                            List<bool> updatedSelection =
                                List.from(state.selectedMemories);
                            // updatedSelection[index] = !updatedSelection[index];
                            updatedSelection[index] = !isSelected;
                            memoryBloc.add(UpdatedSelection(updatedSelection));
                            log('Memory at index $index selected: ${updatedSelection[index]}');
                          },
                          child: Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.red.withValues(alpha: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Delete Memory',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.delete_rounded,
                                      color: AppColors.white),
                                ],
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogWidget(
                                    title: "Delete this memory",
                                    message:
                                        "Are you sure you want to delete this memory? This action cannot be undone!",
                                    icon: Icons.delete_rounded,
                                    noText: "Cancel",
                                    yesText: "Delete",
                                    yesPressed: () =>
                                        Navigator.of(context).pop(true),
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              memoryBloc.add(DeletedMemory(memory: memory));
                            },
                            child: GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  List<bool> updatedSelection =
                                      List.from(state.selectedMemories);
                                  updatedSelection[index] = false;
                                  memoryBloc
                                      .add(UpdatedSelection(updatedSelection));
                                } else {
                                  memoryBloc.add(
                                      MemoryIndexChanged(memoryIndex: index));
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MemoryDetailPage(
                                        memoryBloc: memoryBloc,
                                        memoryAtIndex: index,
                                      ),
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
                                  memoryBloc
                                      .add(UpdatedSelection(updatedSelection));
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }
}
