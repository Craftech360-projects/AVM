import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:friend_private/backend/mixpanel.dart';
import 'package:friend_private/pages/memory_detail/page.dart';
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
  @override
  Widget build(BuildContext context) {
    Structured structured = widget.memory.structured.target!;
    return GestureDetector(
      onTap: () async {
        MixpanelManager()
            .memoryListItemClicked(widget.memory, widget.memoryIdx);
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => MemoryDetailPage(
            
                  memory: widget.memory,
                )));
        widget.loadMemories();
        // FocusScope.of(context).unfocus();
      },
      child: Container(
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
                    ? SizedBox
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
                        onPressed: () {
                          debugPrint('memory_list_item.dart');
                        },
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
