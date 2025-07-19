import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool autoFocus;
  final Widget? suffixIcon;
  final int? minLines;
  final int? maxLines;
  final TextInputType textInputType;
  final Icon? prefixIcon;
  final FocusNode focusNode;
  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.suffixIcon,
    required this.textInputType,
    required this.autoFocus,
    this.minLines,
    this.maxLines,
    this.prefixIcon,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Theme.of(context).primaryColor,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      onTapOutside: (event) {
        focusNode.unfocus();
      },
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      autofocus: autoFocus,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        fillColor: Theme.of(context).primaryColorLight,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        hintFadeDuration: const Duration(milliseconds: 400),
        // labelText: "hintText",
      ),
    );
  }
}
