import 'dart:convert';

import 'package:bloom/authentication_screens/authenticate_object.dart';
import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';

class EntriesTile extends StatelessWidget {
  final String content;
  final String title;
  final String emoji;
  final String date;
  final String? time;
  final String id;
  final String type;
  final String backgroundImageUrl;
  final List attachments;
  final bool hasChildren;
  final bool isFavorite;
  final List children;
  final DateTime addedOn;
  final DateTime dateTime;
  final bool? isSynced;
  final bool isEntryLocked;
  final String? mainId;
  final bool? isTemplate;
  final String? templateType;
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  final BorderRadius? borderRadius;
  EntriesTile({
    super.key,
    required this.content,
    required this.emoji,
    required this.date,
    this.time,
    required this.id,
    required this.type,
    required this.backgroundImageUrl,
    required this.attachments,
    required this.hasChildren,
    required this.children,
    required this.isFavorite,
    required this.addedOn,
    required this.dateTime,
    this.isSynced,
    required this.title,
    this.innerPadding,
    required this.isEntryLocked,
    this.mainId,
    this.isTemplate,
    this.templateType,
    this.decoration,
    this.borderRadius,
  });

  // Required variables
  final userId = FirebaseAuth.instance.currentUser?.uid;

  RichText quillDeltaToRichText(BuildContext context, TextStyle textstyle) {
    final Delta delta = Delta.fromJson(jsonDecode(content));

    // Check if the Delta contains only the default newline character
    if (delta.length == 1 && delta.first.value == '\n') {
      return RichText(
        text: TextSpan(
          text: title,
          style: textstyle,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    // If the content is not empty, process it as usual
    final List<TextSpan> children = [];
    for (final op in delta.toList()) {
      final text = op.value;

      TextStyle textStyle = textstyle;

      children.add(TextSpan(text: text, style: textStyle));
    }

    return RichText(
      text: TextSpan(children: children),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool favorited = isFavorite;
    return Slidable(
      endActionPane: isTemplate == false
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      favorited = !favorited;
                      if (type == 'note') {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('entries')
                            .doc(id)
                            .update({'isFavorite': favorited});
                      } else if (type == 'book') {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .collection('books')
                            .doc(mainId)
                            .collection('pages')
                            .doc(id)
                            .update({'isFavorite': favorited});
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: favorited
                              ? Text('Added to favorites')
                              : Text('Removed from favorites'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.redAccent[400],
                      ),
                      child: isFavorite
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border_rounded),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (isEntryLocked == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text('Unlock the entry to delete it.'),
                          ),
                        );
                      } else {
                        showAdaptiveDialog(
                            context: context,
                            builder: (context) {
                              return DeleteConfirmationDialog(
                                  onPressed: () {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (type == 'note') {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user?.uid)
                                          .collection('entries')
                                          .doc(id)
                                          .delete();
                                    } else if (type == 'book') {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user?.uid)
                                          .collection('books')
                                          .doc(mainId)
                                          .collection('pages')
                                          .doc(id)
                                          .delete();
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        margin: const EdgeInsets.all(6),
                                        behavior: SnackBarBehavior.floating,
                                        showCloseIcon: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        content: Wrap(
                                          children: [
                                            Text('Deleted: '),
                                            quillDeltaToRichText(
                                                context,
                                                TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface))
                                          ],
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  objectName: title);
                            });
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                      child: Icon(Icons.delete_rounded,
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            )
          : null,
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          onTap: () async {
            try {
              // If the entry is a template then do not proceed to display it
              if (isTemplate == false || isTemplate == null) {
                // Check if the entry is locked or not and proceed to display if its not
                if (isEntryLocked) {
                  final bool isAuthenticated = await authenticate(
                      'Please authenticate to open this entry', context);
                  if (isAuthenticated) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteLayout(
                          description: content,
                          title: title,
                          noteId: id,
                          emoji: emoji,
                          backgroundImageUrl: backgroundImageUrl,
                          attachments: [attachments],
                          childNotes: [children],
                          hasChildren: hasChildren,
                          isFavorite: isFavorite,
                          date: date,
                          time: time ?? '',
                          type: type,
                          mode: NoteMode.display,
                          isSynced: isSynced,
                          dateTime: dateTime,
                          isEntryLocked: isAuthenticated,
                        ),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteLayout(
                        description: content,
                        title: title,
                        noteId: id,
                        mainId: mainId,
                        emoji: emoji,
                        backgroundImageUrl: backgroundImageUrl,
                        attachments: [attachments],
                        childNotes: [children],
                        hasChildren: hasChildren,
                        isFavorite: isFavorite,
                        isTemplate: isTemplate,
                        templateType: templateType,
                        date: date,
                        time: time ?? '',
                        type: type,
                        mode: NoteMode.display,
                        isSynced: isSynced,
                        dateTime: dateTime,
                        isEntryLocked: isEntryLocked,
                      ),
                    ),
                  );
                }
              }
            } on LocalAuthException catch (e) {
              if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                        'Set a screen lock to the device to unlock this entry.')));
              }
            }
          },
          child: Container(
            decoration: decoration ?? BoxDecoration(),
            padding: innerPadding ?? const EdgeInsets.all(0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 6,
              children: [
                emoji.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                        child: isEntryLocked
                            ? Icon(
                                Icons.lock_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              )
                            : Text(
                                emoji,
                                style: TextStyle(fontSize: 18),
                              ))
                    : Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                        child: isEntryLocked
                            ? Icon(
                                Icons.lock_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              )
                            : Icon(
                                Icons.note_add_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              )),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.isEmpty ? 'Untitled' : title,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500),
                      ),
                      quillDeltaToRichText(
                          context,
                          TextStyle(
                              color: Colors.grey,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Nunito'))
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Date and time of the entry
                    Text(
                      DateFormat.MEd().format(addedOn),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('h:mm a').format(addedOn),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: const Duration(milliseconds: 50));
  }
}
