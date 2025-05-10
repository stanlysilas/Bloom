// ignore_for_file: must_be_immutable

import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/screens/entries_background_images.dart';
import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreEntryOptions extends StatefulWidget {
  final String? emoji;
  final String type;
  final EmojiNotifier emojiNotifier;
  final BackgroundImageNotifier backgroundImageNotifier;
  bool? isFavorite;
  final Function onDataChanged;
  final DateTime dateTime;
  final int? numberOfWords;
  final bool? syncingStatus;
  final String entryId;
  final String? mainId;
  final bool isEntryLocked;
  final QuillController controller;
  MoreEntryOptions({
    super.key,
    required this.emoji,
    required this.type,
    required this.emojiNotifier,
    this.isFavorite,
    required this.onDataChanged,
    required this.dateTime,
    this.numberOfWords,
    this.syncingStatus,
    required this.backgroundImageNotifier,
    required this.entryId,
    this.mainId,
    required this.isEntryLocked,
    required this.controller,
  });

  @override
  State<MoreEntryOptions> createState() => _MoreEntryOptionsState();
}

class _MoreEntryOptionsState extends State<MoreEntryOptions> {
  final user = FirebaseAuth.instance.currentUser;
  bool? isLocked;
  @override
  void initState() {
    super.initState();
    checkSharedPreferencesIfLocked();
  }

  checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(widget.entryId) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Change emoji option
                      ExtraOptionsButton(
                        icon: widget.emoji == null || widget.emoji!.isEmpty
                            ? const Icon(Icons.emoji_emotions_outlined)
                            : Text(
                                Provider.of<EmojiNotifier>(context)
                                    .emoji
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                        label: 'Change icon',
                        iconLabelSpace: 8,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        innerPadding: const EdgeInsets.all(12),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => EntriesIconPicker(
                                    icon: widget.emoji!,
                                    iconNotifier: widget.emojiNotifier,
                                  )),
                        ),
                        endIcon: const Icon(Iconsax.arrow_right),
                      ),
                      // Change background image option
                      ExtraOptionsButton(
                        icon: const Icon(Icons.image_outlined),
                        label: 'Change background',
                        iconLabelSpace: 8,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        innerPadding: const EdgeInsets.all(12),
                        onTap: () async {
                          final backgroundImage =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => EntriesBackgroundImages(
                                      backgroundImageNotifier:
                                          widget.backgroundImageNotifier,
                                    )),
                          );
                          if (backgroundImage != null) {
                            Navigator.pop(context);
                          } else {
                            // Dont do anything
                          }
                        },
                        endIcon: const Icon(Iconsax.arrow_right),
                      ),
                      // Delete entry option shown only if there is entryId
                      if (widget.entryId.isNotEmpty)
                        ExtraOptionsButton(
                          icon: const Icon(Iconsax.trash),
                          label: 'Delete entry',
                          iconLabelSpace: 8,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          innerPadding: const EdgeInsets.all(12),
                          onTap: () async {
                            if (widget.type == 'note') {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('entries')
                                  .doc(widget.entryId)
                                  .delete();
                            } else if (widget.type == 'book') {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('books')
                                  .doc(widget.mainId)
                                  .collection('pages')
                                  .doc(widget.entryId)
                                  .delete();
                            }
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                  'Succesfully deleted entry',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                ),
                              ),
                            );
                          },
                          endIcon: const Icon(Iconsax.arrow_right),
                        ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Divider(),
              ),
              // Show lock option only if there is an entriesId
              if (widget.entryId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        // Option to lock the entry and unlock it
                        ExtraOptionsButton(
                          label: isLocked == true
                              ? 'Unlock this entry'
                              : 'Lock this entry',
                          iconLabelSpace: 8,
                          icon: isLocked == true
                              ? const Icon(Iconsax.unlock)
                              : const Icon(Iconsax.lock),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                          innerPadding: const EdgeInsets.all(12),
                          endIcon: const Icon(Iconsax.arrow_right),
                          onTap: () async {
                            final LocalAuthentication auth =
                                LocalAuthentication();
                            final bool canAuthenticateWithBiometrics =
                                await auth.canCheckBiometrics;
                            final bool canAuthenticate =
                                canAuthenticateWithBiometrics ||
                                    await auth.isDeviceSupported();
                            final prefs = await SharedPreferences.getInstance();
                            if (canAuthenticate) {
                              try {
                                if (isLocked == true) {
                                  // Try authenticating first
                                  await auth.authenticate(
                                      localizedReason:
                                          'Confirm authentication of this object');
                                  // Set false if its already locked
                                  // Logic to unlock the entry
                                  setState(() {
                                    isLocked = false;
                                  });
                                  if (widget.type == 'note') {
                                    prefs.setBool(
                                        widget.entryId, isLocked ?? false);
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection('entries')
                                        .doc(widget.entryId)
                                        .update({
                                      'isEntryLocked': isLocked,
                                    });
                                  } else if (widget.type == 'book') {
                                    prefs.setBool(
                                        widget.entryId, isLocked ?? false);
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection('books')
                                        .doc(widget.mainId)
                                        .collection('pages')
                                        .doc(widget.entryId)
                                        .update({
                                      'isEntryLocked': isLocked,
                                    });
                                  }
                                  // Go back to entries screen
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          margin: const EdgeInsets.all(6),
                                          behavior: SnackBarBehavior.floating,
                                          showCloseIcon: true,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Text(
                                            'Entry Unlocked',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
                                          )));
                                } else {
                                  // Try authenticating first
                                  await auth.authenticate(
                                      localizedReason:
                                          'Confirm authentication of this object');
                                  // Set true and lock if not locked
                                  // Logic to lock the entry
                                  setState(() {
                                    isLocked = true;
                                  });
                                  if (widget.type == 'note') {
                                    prefs.setBool(
                                        widget.entryId, isLocked ?? true);
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection('entries')
                                        .doc(widget.entryId)
                                        .update({
                                      'isEntryLocked': isLocked,
                                    });
                                  } else if (widget.type == 'book') {
                                    prefs.setBool(
                                        widget.entryId, isLocked ?? true);
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user?.uid)
                                        .collection('books')
                                        .doc(widget.mainId)
                                        .collection('pages')
                                        .doc(widget.entryId)
                                        .update({
                                      'isEntryLocked': isLocked,
                                    });
                                  }
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          margin: const EdgeInsets.all(6),
                                          behavior: SnackBarBehavior.floating,
                                          showCloseIcon: true,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Text(
                                            'Entry Locked',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
                                          )));
                                }
                              } on PlatformException catch (e) {
                                //
                                if (e.code == 'NotAvailable') {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          margin: const EdgeInsets.all(6),
                                          behavior: SnackBarBehavior.floating,
                                          showCloseIcon: true,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Text(
                                            'Set a screen lock to the device to use this feature.',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
                                          )));
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          margin: const EdgeInsets.all(6),
                                          behavior: SnackBarBehavior.floating,
                                          showCloseIcon: true,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Text(
                                            'Failed to lock entry: ${e.code}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
                                          )));
                                }
                              }
                            }
                          },
                        ),
                        // Option to export the note as a PDF or DOCX file
                        // ExtraOptionsButton(
                        //   icon: const Icon(Iconsax.document),
                        //   iconLabelSpace: 8,
                        //   label: 'Export PDF',
                        //   labelStyle: const TextStyle(
                        //       fontWeight: FontWeight.w600, fontSize: 16),
                        //   innerPadding: const EdgeInsets.all(12),
                        //   endIcon: const Icon(Iconsax.arrow_right),
                        //   onTap: () {
                        //     // Do something to export it as PDF
                        //     PDFConverter(
                        //       params: PDFPageFormat.a4,
                        //       document: widget.controller.document.toDelta(),
                        //       frontMatterDelta: null,
                        //       backMatterDelta: null,
                        //       customConverters: [],
                        //       onRequestBoldFont: (p0) {
                        //         final loader = FontLoader('Nunito');
                        //         loader. ;
                        //         return FontLoader('Nunito').load('');
                        //       },
                        //       onRequestBoldItalicFont: (p0) {},
                        //       onRequestFallbackFont: (p0) {},
                        //       onRequestFont: (p0) {},
                        //       onRequestItalicFont: (p0) {},
                        //       fallbacks: [],
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
                  width: double.maxFinite,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Syncing status: ${widget.syncingStatus! ? 'Syncing' : 'Synced'}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'Character count: ${widget.numberOfWords}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'Last edited by: You',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        'On: ${DateFormat('dd, LLL yyyy').format(widget.dateTime)} at ${DateFormat('h:mm a').format(widget.dateTime)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
