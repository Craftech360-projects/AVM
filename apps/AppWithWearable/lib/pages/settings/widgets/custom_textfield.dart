import 'package:flutter/material.dart';
import 'package:friend_private/core_updated/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.hintText,
    this.labelText,
    super.key,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.borderColor,
    this.fillColor,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    this.showLabel = true,
    this.autofocus = false,
    this.style,
  });

  final FocusNode? focusNode;
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final TextInputType keyboardType;
  final Color? borderColor;
  final Color? fillColor;
  final bool obscureText;
  final void Function(String?)? onChanged;
  final String? Function(String?)? onSubmitted;
  final String? Function(String?)? validator;
  final int minLines;
  final int? maxLines;
  final bool enabled;
  final bool showLabel;
  final bool autofocus;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel && labelText != null)
            Text(
              labelText!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          if (showLabel) const SizedBox(height: 8),
          TextFormField(
            focusNode: focusNode,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: minLines,
            enabled: enabled,
            onChanged: onChanged,
            autofocus: autofocus,
            onFieldSubmitted: onSubmitted,
            style: style ?? Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade300,
                  ),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  wordSpacing: 2),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey.shade800,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: borderColor ?? Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor ?? AppColors.greyLavender,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
