import 'package:capsoul/core/constants/constants.dart';
import 'package:capsoul/core/theme/app_colors.dart';
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
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  title ?? '',
                  style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  constraints: BoxConstraints(maxWidth: 250),
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(0, 238, 228, 255),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.grey,
                      size: 16,
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
