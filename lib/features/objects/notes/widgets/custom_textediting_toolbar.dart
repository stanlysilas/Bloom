import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomHorizontalTextEditingToolbar extends StatelessWidget {
  final QuillController controller;
  const CustomHorizontalTextEditingToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context);

    return QuillSimpleToolbar(
        controller: controller,
        config: QuillSimpleToolbarConfig(
          axis: Axis.horizontal,
          showLink: false,
          showSmallButton: true,
          showAlignmentButtons: true,
          showDirection: true,
          dialogTheme: QuillDialogTheme(
              dialogBackgroundColor: colors.scaffoldBackgroundColor),
          multiRowsDisplay: false,
          color: Colors.transparent,
          buttonOptions: QuillSimpleToolbarButtonOptions(
            base: QuillToolbarBaseButtonOptions(
                iconTheme: QuillIconTheme(
                    iconButtonUnselectedData: IconButtonData(
                      color: colors.textTheme.bodyMedium?.color,
                    ),
                    iconButtonSelectedData: IconButtonData(
                      color: colors.scaffoldBackgroundColor,
                    ))),
            color: QuillToolbarColorButtonOptions(
                iconData: Icons.color_lens,
                iconTheme: QuillIconTheme(
                    iconButtonUnselectedData: IconButtonData(
                      color: colors.textTheme.bodyMedium?.color,
                    ),
                    iconButtonSelectedData: IconButtonData(
                      color: colors.scaffoldBackgroundColor,
                    ))),
            search: QuillToolbarSearchButtonOptions(
              dialogTheme: QuillDialogTheme(
                  dialogBackgroundColor: colors.primaryColorLight),
            ),
          ),
        ));
  }
}
