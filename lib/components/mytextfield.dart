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
  });

  @override
  Widget build(BuildContext context) {
    final textFieldFocusNode = FocusNode();
    return TextField(
      cursorColor: Theme.of(context).primaryColor,
      focusNode: textFieldFocusNode,
      minLines: minLines,
      maxLines: maxLines,
      onTapOutside: (event) {
        textFieldFocusNode.unfocus();
      },
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      autofocus: autoFocus,
      decoration: InputDecoration(
        fillColor: Theme.of(context).primaryColorLight,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          color: Colors.grey,
        ),
        hintFadeDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
