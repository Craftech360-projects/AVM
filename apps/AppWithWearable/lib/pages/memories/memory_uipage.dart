import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:friend_private/backend/database/memory.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key, required this.memories});
  final List<Memory> memories;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            // margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: GradientBoxBorder(
                gradient: LinearGradient(colors: [
                  Color.fromARGB(127, 208, 208, 208),
                  Color.fromARGB(127, 188, 99, 121),
                  Color.fromARGB(127, 86, 101, 182),
                  Color.fromARGB(127, 126, 190, 236)
                ]),
                width: 1,
              ),
              shape: BoxShape.rectangle,
            ),
            child: TextField(
              enabled: true,
              // controller: textController,
              onChanged: (s) {
                // setState(() {});
              },
              obscureText: false,
              autofocus: false,
              // focusNode: widget.textFieldFocusNode,
              decoration: const InputDecoration(
                hintText: 'Search for memories...',
                hintStyle: TextStyle(fontSize: 14.0, color: Colors.grey),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                // suffixIcon: textController.text.isEmpty
                //     ? const SizedBox.shrink()
                //     : IconButton(
                //         icon: const Icon(
                //           Icons.cancel,
                //           color: Color(0xFFF7F4F4),
                //           size: 28.0,
                //         ),
                //         onPressed: () {
                //           textController.clear();
                //           setState(() {});
                //         },
                //       ),
              ),
              style: TextStyle(fontSize: 14.0, color: Colors.grey.shade200),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  // onPressed: _onAddButtonPressed,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 24,
                    color: Colors.white,
                  )),
              const SizedBox(width: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    // displayDiscardMemories
                    //     ? 'Hide Discarded'
                    // :
                    'Show Discarded',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // _toggleDiscardMemories();
                    },
                    icon: const Icon(
                      // displayDiscardMemories
                      //     ? Icons.cancel_outlined
                      // :
                      Icons.filter_list,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: memories.length,
              itemBuilder: (BuildContext context, int index) {
                final memory = memories[index];
                //                this.createdAt,
                // this.transcript,
                // this.discarded, {
                // this.id = 0,
                // this.recordingFilePath,
                // this.startedAt,
                // this.finishedAt,
                print(
                    'created at: ${memory.createdAt},discarded:${memory.discarded},transcript:${memory.transcript},id:${memory.id},recording filepath:${memory.recordingFilePath},startedat:${memory.startedAt},finishedat:${memory.finishedAt}');

                return Card(
                  elevation: 0,
                  color: Color.fromARGB(35, 255, 255, 255),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://cdna.artstation.com/p/assets/images/images/065/204/124/large/madan-asset.jpg?1689779452',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              memory.structured.target?.title ?? '',
                              // "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text(
                              memory.structured.target?.overview ?? '',
                              // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 8),
                            Divider(),
                            Row(
                              children: [
                                Text(
                                    'Created At: ${DateFormat.yMd().add_jm().format(memory.createdAt)}',
                                    // 'Sunday 16 Jun',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    debugPrint(
                                        'navigate to memory detail page');
                                  },
                                  icon: Icon(
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
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
