import 'dart:convert';

import 'package:bloom/authentication_screens/lock_object_method.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

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
  });

  // Required variables
  final userId = FirebaseAuth.instance.currentUser?.uid;

  RichText quillDeltaToRichText(BuildContext context, TextStyle textstyle) {
    final Delta delta = Delta.fromJson(jsonDecode(content));

    // Check if the Delta contains only the default newline character
    if (delta.length == 1 && delta.first.value == '\n') {
      return RichText(
        text: TextSpan(
          text: 'Untitled',
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
      endActionPane: ActionPane(
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
                    closeIconColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: favorited
                        ? Text(
                            'Added to favorites',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                          )
                        : Text(
                            'Removed from favorites',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                          ),
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
                    ? Icon(
                        Icons.favorite,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      )
                    : Icon(
                        Icons.favorite_border_rounded,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
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
                    closeIconColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Wrap(
                      children: [
                        Text(
                          'Deleted: ',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                        quillDeltaToRichText(
                            context,
                            TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                overflow: TextOverflow.ellipsis,
                                fontFamily: 'Nunito'))
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red,
                ),
                child: Icon(
                  Iconsax.trash,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          try {
            // If the entry is a template then do not proceed to display it
            if (isTemplate == false || isTemplate == null) {
              // Check if the entry is locked or not and proceed to display if its not
              if (isEntryLocked) {
                final bool isAuthenticated = await checkForBiometrics(
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
          } catch (e) {
            //
          }
        },
        child: Padding(
          padding: innerPadding ?? const EdgeInsets.all(0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: isEntryLocked
                    ? const Icon(
                        Iconsax.lock,
                        size: 18,
                      )
                    : Text(
                        emoji,
                      ),
              ),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Untitled' : title,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Date and time of the entry
                  Text(
                    DateFormat.MEd().format(addedOn),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(DateFormat('h:mm a').format(addedOn)),
                ],
              )
            ],
          ),
        ),
      ),
    ).animate().fade(delay: const Duration(milliseconds: 50));
  }
}
