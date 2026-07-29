import 'package:bloom/core/widgets/bloom_textfield.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final TextInputType textInputType;
  final bool obscureText;
  final bool autoFocus;
  final Widget suffixIcon;
  final double? spacing;
  final EdgeInsets? titlePadding;
  final EdgeInsets? textFieldPadding;
  const AuthTextField(
      {super.key,
      required this.title,
      required this.controller,
      required this.focusNode,
      this.hintText,
      required this.textInputType,
      required this.obscureText,
      required this.autoFocus,
      required this.suffixIcon,
      this.spacing,
      this.titlePadding,
      this.textFieldPadding});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: spacing ?? 5,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: titlePadding ?? const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding:
              textFieldPadding ?? const EdgeInsets.symmetric(horizontal: 10.0),
          child: BloomTextfield(
            controller: controller,
            focusNode: focusNode,
            hintText: hintText ?? '',
            textInputType: textInputType,
            obscureText: obscureText,
            autoFocus: autoFocus,
            suffixIcon: suffixIcon,
            maxLines: obscureText ? 1 : null,
          ),
        ),
      ],
    );
  }
}
