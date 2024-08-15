import 'package:flutter/material.dart';

class EditableTitle extends StatefulWidget {
  final String initialTitle;
  final Function(String) onTitleChanged;
  final bool discarded;
  final TextStyle style;

  const EditableTitle({
    super.key,
    required this.initialTitle,
    required this.onTitleChanged,
    required this.discarded,
    required this.style,
  });

  @override
  _EditableTitleState createState() => _EditableTitleState();
}

class _EditableTitleState extends State<EditableTitle> {
  late TextEditingController _controller;
  bool _isEditing = false;
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialTitle;
    _controller = TextEditingController(text: _currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: _isEditing
          ? TextField(
              controller: _controller,
              onSubmitted: (newTitle) {
                setState(() {
                  _isEditing = false;
                  _currentTitle = newTitle;
                });
                widget.onTitleChanged(newTitle);
              },
              autofocus: true,
              style: widget.style,
              maxLines: null, 
              minLines: 1,
              expands: false, 
              textInputAction: TextInputAction.done,
            )
          : Text(
              widget.discarded ? 'Discarded Memory' : _currentTitle,
              style: widget.style,
            ),
    );
  }
}
