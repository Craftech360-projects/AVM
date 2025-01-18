import 'dart:developer';

import 'package:capsaul/backend/database/memory.dart';
import 'package:capsaul/backend/database/memory_provider.dart';
import 'package:capsaul/backend/mixpanel.dart';
import 'package:capsaul/features/memories/bloc/memory_bloc.dart';
import 'package:capsaul/features/memories/pages/memory_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MemoryListItem extends StatefulWidget {
  final int memoryIdx;
  final Memory memory;
  final Function loadMemories;

  const MemoryListItem({
    super.key,
    required this.memory,
    required this.loadMemories,
    required this.memoryIdx,
  });

  @override
  State<MemoryListItem> createState() => _MemoryListItemState();
}

class _MemoryListItemState extends State<MemoryListItem> {
  late Memory memory;

  @override
  void initState() {
    super.initState();
    memory = widget.memory;
  }

  Future<void> _refreshMemory() async {
    Memory? updatedMemory = MemoryProvider().getMemoryById(memory.id);

    if (updatedMemory != null) {
      setState(() {
        memory = updatedMemory;
      });
    } else {
      log('Memory not found in database.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Structured structured = widget.memory.structured.target!;

    return GestureDetector(
      onTap: () async {
        MixpanelManager()
            .memoryListItemClicked(widget.memory, widget.memoryIdx);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => MemoryDetailPage(
                  memoryBloc: context.read<MemoryBloc>(),
                  memoryAtIndex: widget.memoryIdx,
                )));

        await _refreshMemory();

        widget.loadMemories();
        // FocusScope.of(context).unfocus();
      },
      child: Container(
        key: UniqueKey(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        margin: const EdgeInsets.only(top: 12, left: 8, right: 8),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: const Color.fromARGB(35, 255, 255, 255),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(16),
                ),
                child: widget.memory.memoryImg == null
                    ? const SizedBox
                        .shrink() // or any other widget to represent an empty state
                    : Image.memory(
                        widget.memory.memoryImg!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.memory.discarded
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 16),
                  widget.memory.discarded
                      ? const SizedBox.shrink()
                      : Text(
                          structured.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                        ),
                  widget.memory.discarded
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 8),
                  widget.memory.discarded
                      ? const SizedBox.shrink()
                      : Text(
                          structured.overview,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Colors.grey.shade300, height: 1.3),
                          maxLines: 2,
                        ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 0,
                    thickness: 1,
                  ),
                  Row(
                    children: [
                      Text(
                        'Created At: ${DateFormat('EE d MMM h:mm a').format(widget.memory.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: const VisualDensity(vertical: -4),
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
