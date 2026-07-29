import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';

RichText quillDeltaToRichText(
    BuildContext context, String? title, String content) {
  final Delta delta = Delta.fromJson(jsonDecode(content));
  final colors = Theme.of(context).colorScheme;
  final textStyle = TextStyle(
      color: colors.inverseSurface,
      fontFamily: 'Nunito',
      fontFamilyFallback: ['AppleEmoji']);

  if (delta.length == 1 && delta.first.value == '\n') {
    return RichText(
      text: TextSpan(
        text: title ?? 'Untitled',
        style: textStyle,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  final List<TextSpan> children = [];
  for (final op in delta.toList()) {
    final text = op.value;

    children.add(TextSpan(text: text, style: textStyle));
  }

  return RichText(
    text: TextSpan(children: children),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
