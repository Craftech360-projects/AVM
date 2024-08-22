import 'package:flutter/material.dart';
import 'package:friend_private/features/memory/presentation/bloc/memory_bloc.dart';

class MemorySearchWidget extends StatelessWidget {
  const MemorySearchWidget({
    super.key,
    required TextEditingController searchController,
    required MemoryBloc memoryBloc,
  })  : _searchController = searchController,
        _memoryBloc = memoryBloc;

  final TextEditingController _searchController;
  final MemoryBloc _memoryBloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: Colors.grey,
        ),
        shape: BoxShape.rectangle,
      ),
      child: TextField(
        enabled: true,
        controller: _searchController,
        // onChanged: (s) {
        //   print('search $s');
        //   setState(() {});
        // },
        obscureText: false,
        autofocus: false,
        // focusNode: widget.textFieldFocusNode,
        decoration: InputDecoration(
          hintText: 'Search for memories...',
          hintStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: _searchController.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xFFF7F4F4),
                    size: 28.0,
                  ),
                  onPressed: () {
                    _searchController.clear();

                    _memoryBloc.add(const SearchMemory(query: ''));
                  },
                ),
        ),
        style: TextStyle(fontSize: 14.0, color: Colors.grey.shade200),
      ),
    );
  }
}
