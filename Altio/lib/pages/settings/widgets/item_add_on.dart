import 'package:altio/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ItemAddOn extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final bool? visibility;
  final IconData icon;
  const ItemAddOn(
      {super.key, this.title, this.onTap, required this.icon, this.visibility});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibility ?? true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 255, 255),
            borderRadius: br12,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Text(
                  title ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
