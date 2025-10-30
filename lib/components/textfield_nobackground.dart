import 'package:flutter/material.dart';

class MyTextfieldNobackground extends StatelessWidget {
  final TextEditingController controller;
  final String? text;
  final TextStyle? style;
  final int? minLines;
  final int? maxLines;
  final String hintText;
  final FocusNode focusNode;
  final bool readOnly;
  final bool autoFocus;
  final Widget? suffixIcon;
  final Color? suffixIconColor;
  const MyTextfieldNobackground({
    super.key,
    required this.controller,
    this.text,
    this.style,
    this.minLines,
    this.maxLines,
    required this.hintText,
    required this.focusNode,
    required this.readOnly,
    this.suffixIcon,
    this.suffixIconColor,
    required this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: style,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autoFocus,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(0),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        suffixIcon: suffixIcon,
        suffixIconColor: suffixIconColor,
      ),
      onTapOutside: (event) {
        focusNode.unfocus();
      },
    );
  }
}
