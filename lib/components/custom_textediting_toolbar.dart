import 'package:bloom/models/note_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class CustomTexteditingToolbar extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final VoidCallback onSelected;
  const CustomTexteditingToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSelected,
  });

  @override
  State<CustomTexteditingToolbar> createState() =>
      _CustomTexteditingToolbarState();
}

class _CustomTexteditingToolbarState extends State<CustomTexteditingToolbar> {
  // Required variables
  late QuillController controller;

  // Init state for initializing
  @override
  void initState() {
    super.initState();
    setState(() {
      controller = widget.controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusProvider = Provider.of<EditorFocusProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Basic',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  axis: Axis.horizontal,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showAlignmentButtons: false,
                  showCenterAlignment: false,
                  showLink: false,
                  showDividers: false,
                  showIndent: false,
                  showJustifyAlignment: false,
                  showLeftAlignment: false,
                  showListBullets: false,
                  showQuote: false,
                  showListCheck: false,
                  showRightAlignment: false,
                  showListNumbers: false,
                  showBoldButton: false,
                  showClearFormat: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showItalicButton: false,
                  showSmallButton: false,
                  showDirection: false,
                  showStrikeThrough: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showUnderLineButton: false,
                  showLineHeightButton: false,
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    undoHistory: QuillToolbarHistoryButtonOptions(
                      iconData: Iconsax.undo,
                      afterButtonPressed: () {
                        focusProvider.unfocusEditor();
                      },
                    ),
                    redoHistory: QuillToolbarHistoryButtonOptions(
                      iconData: Iconsax.redo,
                      afterButtonPressed: () {
                        focusProvider.unfocusEditor();
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Text font formatiing options
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Text formatting',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  axis: Axis.horizontal,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  showUndo: false,
                  showRedo: false,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showAlignmentButtons: false,
                  showCenterAlignment: false,
                  showClipboardCopy: false,
                  showClipboardCut: false,
                  showClipboardPaste: false,
                  showLink: false,
                  showDividers: false,
                  showIndent: false,
                  showJustifyAlignment: false,
                  showLeftAlignment: false,
                  showListBullets: false,
                  showQuote: false,
                  showListCheck: false,
                  showRightAlignment: false,
                  showSearchButton: false,
                  showListNumbers: false,
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    fontFamily: QuillToolbarFontFamilyButtonOptions(
                      onSelected: (value) {
                        focusProvider.unfocusEditor();
                      },
                    ),
                    // Custom bold buttom
                    bold: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        setState(() {
                          widget.focusNode.unfocus();
                          widget.controller.editorFocusNode!.unfocus();
                          widget.onSelected();
                        });
                      },
                      childBuilder: (options, extraOptions) {
                        var isBold = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.bold.key);
                        return Builder(
                          builder: (context) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isBold
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_bold,
                                color: isBold
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                    : Colors.black,
                              ),
                              onPressed: () {
                                options.afterButtonPressed!();
                                setState(() {
                                  if (isBold) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.bold, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.bold);
                                    options.afterButtonPressed!();
                                  }
                                  isBold = !isBold;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom italic button
                    italic: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isItalic = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.italic.key);
                        return Builder(
                          builder: (context) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isItalic
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_italic,
                                color: isItalic
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                options.afterButtonPressed!();
                                setState(() {
                                  if (isItalic) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.italic, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.italic);
                                    options.afterButtonPressed!();
                                  }
                                  isItalic = !isItalic;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom underline button
                    underLine: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isUnderline = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.underline.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isUnderline
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_underline,
                                color: isUnderline
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isUnderline) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.underline, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.underline);
                                    options.afterButtonPressed!();
                                  }
                                  isUnderline = !isUnderline;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom strikethrough button
                    strikeThrough: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isStrikethrough = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.strikeThrough.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isStrikethrough
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_strikethrough,
                                color: isStrikethrough
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isStrikethrough) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.strikeThrough, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller.formatSelection(
                                        Attribute.strikeThrough);
                                    options.afterButtonPressed!();
                                  }
                                  isStrikethrough = !isStrikethrough;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom subscript button
                    subscript: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isSubscript = widget.controller
                                .getSelectionStyle()
                                .attributes[Attribute.subscript.key] ==
                            Attribute.subscript;
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isSubscript
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.subscript,
                                color: isSubscript
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isSubscript) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.subscript, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.superscript, null));
                                    widget.controller
                                        .formatSelection(Attribute.subscript);
                                    options.afterButtonPressed!();
                                  }
                                  isSubscript = !isSubscript;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom superscript button
                    superscript: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isSuperscript = widget.controller
                                .getSelectionStyle()
                                .attributes[Attribute.superscript.key] ==
                            Attribute.superscript;
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isSuperscript
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.superscript,
                                color: isSuperscript
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isSuperscript) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.superscript, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.subscript, null));
                                    widget.controller
                                        .formatSelection(Attribute.superscript);
                                    options.afterButtonPressed!();
                                  }
                                  isSuperscript = !isSuperscript;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Lists, alignment and ordering formatting options
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Alignment & lists',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  axis: Axis.horizontal,
                  toolbarIconAlignment: WrapAlignment.start,
                  multiRowsDisplay: false,
                  showBackgroundColorButton: false,
                  showBoldButton: false,
                  showClearFormat: false,
                  showClipboardCopy: false,
                  showCodeBlock: false,
                  showClipboardCut: false,
                  showClipboardPaste: false,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showInlineCode: false,
                  showItalicButton: false,
                  showLink: false,
                  showQuote: false,
                  showRedo: false,
                  showUnderLineButton: false,
                  showSearchButton: false,
                  showSmallButton: false,
                  showStrikeThrough: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showUndo: false,
                  showColorButton: false,
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    // Custom numbered list button
                    listNumbers: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isListNumbers = widget.controller
                                .getSelectionStyle()
                                .attributes[Attribute.list.key] ==
                            Attribute.ol;
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isListNumbers
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_list_numbered,
                                color: isListNumbers
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isListNumbers) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.ol, null));
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.unchecked, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.ul, null));
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.unchecked, null));
                                    widget.controller
                                        .formatSelection(Attribute.ol);
                                    options.afterButtonPressed!();
                                  }
                                  isListNumbers = !isListNumbers;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom bulleted list button
                    listBullets: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isListBullets = widget.controller
                                .getSelectionStyle()
                                .attributes[Attribute.list.key] ==
                            Attribute.ul;
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isListBullets
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_list_bulleted,
                                color: isListBullets
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isListBullets) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.ul, null));
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.unchecked, null));
                                  } else {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.ol, null));
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.unchecked, null));
                                    widget.controller
                                        .formatSelection(Attribute.ul);
                                    options.afterButtonPressed!();
                                  }
                                  isListBullets = !isListBullets;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom checkbox button
                    toggleCheckList: QuillToolbarToggleCheckListButtonOptions(
                      childBuilder: (options, extraOptions) {
                        var isToggleChecklist = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.unchecked.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isToggleChecklist
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.check_box,
                                color: isToggleChecklist
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isToggleChecklist) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.unchecked, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.unchecked);
                                    options.afterButtonPressed!();
                                  }
                                  isToggleChecklist = !isToggleChecklist;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Decoration text formatting options
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Text decoration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  axis: Axis.horizontal,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  showBoldButton: false,
                  showClearFormat: false,
                  showClipboardCopy: false,
                  showCodeBlock: false,
                  showClipboardCut: false,
                  showClipboardPaste: false,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showInlineCode: false,
                  showItalicButton: false,
                  showLink: false,
                  showRedo: false,
                  showUnderLineButton: false,
                  showSearchButton: false,
                  showSmallButton: false,
                  showStrikeThrough: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showUndo: false,
                  showListBullets: false,
                  showListCheck: false,
                  showListNumbers: false,
                  showLeftAlignment: false,
                  showCenterAlignment: false,
                  showIndent: false,
                  showJustifyAlignment: false,
                  showRightAlignment: false,
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    // Custom quote block button
                    quote: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isQuote = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.blockQuote.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isQuote
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.format_quote,
                                color: isQuote
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isQuote) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.blockQuote, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.blockQuote);
                                    options.afterButtonPressed!();
                                  }
                                  isQuote = !isQuote;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Other Advanced text formatting options
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Other advanced',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            Center(
              child: QuillSimpleToolbar(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: widget.controller,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                  axis: Axis.horizontal,
                  multiRowsDisplay: false,
                  toolbarIconAlignment: WrapAlignment.start,
                  showBoldButton: false,
                  showClearFormat: false,
                  showClipboardCopy: false,
                  showClipboardCut: false,
                  showClipboardPaste: false,
                  showDividers: false,
                  showFontFamily: false,
                  showFontSize: false,
                  showHeaderStyle: false,
                  showItalicButton: false,
                  showRedo: false,
                  showUnderLineButton: false,
                  showSearchButton: false,
                  showSmallButton: false,
                  showStrikeThrough: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showUndo: false,
                  showListBullets: false,
                  showListCheck: false,
                  showListNumbers: false,
                  showLeftAlignment: false,
                  showCenterAlignment: false,
                  showIndent: false,
                  showJustifyAlignment: false,
                  showRightAlignment: false,
                  showAlignmentButtons: false,
                  showBackgroundColorButton: false,
                  showColorButton: false,
                  showDirection: false,
                  showLineHeightButton: false,
                  showQuote: false,
                  buttonOptions: QuillSimpleToolbarButtonOptions(
                    // Custom inline code button
                    inlineCode: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isInlineCode = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.inlineCode.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isInlineCode
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Iconsax.code,
                                color: isInlineCode
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isInlineCode) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.inlineCode, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.inlineCode);
                                    options.afterButtonPressed!();
                                  }
                                  isInlineCode = !isInlineCode;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom code block button
                    codeBlock: QuillToolbarToggleStyleButtonOptions(
                      afterButtonPressed: () {
                        widget.focusNode.unfocus();
                        widget.controller.editorFocusNode!.unfocus();
                      },
                      childBuilder: (options, extraOptions) {
                        var isCodeBlock = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.codeBlock.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isCodeBlock
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Icons.code,
                                color: isCodeBlock
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isCodeBlock) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(
                                            Attribute.codeBlock, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.codeBlock);
                                    options.afterButtonPressed!();
                                  }
                                  isCodeBlock = !isCodeBlock;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    // Custom link button
                    linkStyle: QuillToolbarLinkStyleButtonOptions(
                      childBuilder: (options, extraOptions) {
                        var isLinkStyle = widget.controller
                            .getSelectionStyle()
                            .attributes
                            .containsKey(Attribute.link.key);
                        return StatefulBuilder(
                          builder: (context, state) {
                            return IconButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      isLinkStyle
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent),
                                  shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              icon: Icon(
                                Iconsax.link,
                                color: isLinkStyle
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isLinkStyle) {
                                    widget.controller.formatSelection(
                                        Attribute.clone(Attribute.link, null));
                                    options.afterButtonPressed!();
                                  } else {
                                    widget.controller
                                        .formatSelection(Attribute.link);
                                    options.afterButtonPressed!();
                                  }
                                  isLinkStyle = !isLinkStyle;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomHorizontalTextEditingToolbar extends StatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  const CustomHorizontalTextEditingToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<CustomHorizontalTextEditingToolbar> createState() =>
      _CustomHorizontalTextEditingToolbarState();
}

class _CustomHorizontalTextEditingToolbarState
    extends State<CustomHorizontalTextEditingToolbar> {
  @override
  Widget build(BuildContext context) {
    return QuillSimpleToolbar(
        configurations: QuillSimpleToolbarConfigurations(
      controller: widget.controller,
      showLink: false,
      showSmallButton: true,
      showAlignmentButtons: true,
      showDirection: true,
      sharedConfigurations: QuillSharedConfigurations(
          dialogTheme: QuillDialogTheme(
              dialogBackgroundColor:
                  Theme.of(context).scaffoldBackgroundColor)),
      toolbarSize: 50,
      multiRowsDisplay: false,
      color: Theme.of(context).primaryColorLight,
      buttonOptions: QuillSimpleToolbarButtonOptions(
        base: QuillToolbarBaseButtonOptions(
            afterButtonPressed: () {
              setState(() {
                widget.controller.editorFocusNode!.unfocus();
                widget.focusNode.unfocus();
              });
            },
            iconTheme: QuillIconTheme(
                iconButtonUnselectedData: IconButtonData(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                iconButtonSelectedData: IconButtonData(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ))),
        color: QuillToolbarColorButtonOptions(
            iconData: Icons.color_lens,
            iconTheme: QuillIconTheme(
                iconButtonUnselectedData: IconButtonData(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                iconButtonSelectedData: IconButtonData(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ))),
        search: QuillToolbarSearchButtonOptions(
          dialogTheme: QuillDialogTheme(
              dialogBackgroundColor: Theme.of(context).primaryColorLight),
        ),
      ),
    ));
  }
}
