import 'package:flutter/material.dart';
import 'package:AVMe/backend/storage/message.dart';

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
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(120, 130, 129, 131),
                  Color.fromARGB(120, 99, 97, 101),
                  Color.fromARGB(122, 49, 11, 125),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              border: Border.all(
                color: Color.fromARGB(171, 84, 84, 84),
                width: 1,
              ),
              shape: BoxShape.rectangle,
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
