import 'package:flutter/material.dart';

class RecogniseVoice extends StatelessWidget {
  const RecogniseVoice({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.mic_external_on_sharp),
    );
  }
}
