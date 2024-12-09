import 'package:flutter/material.dart';

import '../../../backend/database/message.dart';

class HumanMessage extends StatelessWidget {
  final Message message;

  const HumanMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: Wrap(
        alignment: WrapAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    // Color.fromARGB(108, 255, 255, 255),
                    // Color.fromARGB(80, 0, 0, 0),
                    // Color.fromARGB(101, 255, 255, 255)
                    Color.fromARGB(127, 208, 208, 208),
                    Color.fromARGB(127, 188, 99, 121),
                    Color.fromARGB(127, 86, 101, 182),
                    Color.fromARGB(127, 126, 190, 236)
                  ],
                  begin: Alignment.topLeft,
                  end: FractionalOffset.bottomRight,
                  transform: GradientRotation(90)),
              // color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
