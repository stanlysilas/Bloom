// ignore_for_file: must_be_immutable

import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/screens/entries_background_images.dart';
import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  final TextEditingController titleController;
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
    required this.titleController,
  });

  @override
  State<MoreEntryOptions> createState() => _MoreEntryOptionsState();
}

class _MoreEntryOptionsState extends State<MoreEntryOptions> {
  final user = FirebaseAuth.instance.currentUser;
  bool? isLocked;
  String? profilePicture;
  String? email;
  String? userName = '';
  bool? isImageNetwork;
  @override
  void initState() {
    super.initState();
    checkSharedPreferencesIfLocked();
    fetchAccountData();
  }

  Future<void> checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(widget.entryId) ?? false;
    });
  }

  // Fetch accountData
  void fetchAccountData() async {
    // Replace 'users' with your actual collection name
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      setState(() {
        profilePicture = data?['profilePicture'];
        email = data?['email'];
        userName = data?['userName'];
        isImageNetwork = data?['isImageNetwork'];
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                // Change emoji option
                BloomModalListTile(
                  leadingIcon: widget.emoji == null || widget.emoji!.isEmpty
                      ? Icon(Icons.emoji_emotions_outlined)
                      : Text(
                          Provider.of<EmojiNotifier>(context).emoji.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                  title: 'Change icon',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => EntriesIconPicker(
                              icon: widget.emoji!,
                              iconNotifier: widget.emojiNotifier,
                            )),
                  ),
                ),
                // Change background image option
                BloomModalListTile(
                  leadingIcon: Icon(Icons.image_outlined),
                  title: 'Change background',
                  onTap: () async {
                    final backgroundImage = await Navigator.of(context).push(
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
                ),
                // Show lock option only if there is an entriesId
                if (widget.entryId.isNotEmpty)
                  BloomModalListTile(
                    title: isLocked == true
                        ? 'Unlock this entry'
                        : 'Lock this entry',
                    leadingIcon: Icon(isLocked == true
                        ? Icons.lock_open_rounded
                        : Icons.lock_rounded),
                    onTap: () async {
                      final LocalAuthentication auth = LocalAuthentication();
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
                              prefs.setBool(widget.entryId, isLocked ?? false);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('entries')
                                  .doc(widget.entryId)
                                  .update({
                                'isEntryLocked': isLocked,
                              });
                            } else if (widget.type == 'book') {
                              prefs.setBool(widget.entryId, isLocked ?? false);
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text('Entry Unlocked')));
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
                              prefs.setBool(widget.entryId, isLocked ?? true);
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('entries')
                                  .doc(widget.entryId)
                                  .update({
                                'isEntryLocked': isLocked,
                              });
                            } else if (widget.type == 'book') {
                              prefs.setBool(widget.entryId, isLocked ?? true);
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text('Entry Locked')));
                          }
                        } on PlatformException catch (e) {
                          //
                          if (e.code == 'NotAvailable') {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                    'Set a screen lock to the device to use this feature.')));
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content:
                                    Text('Failed to lock entry: ${e.code}')));
                          }
                        } on LocalAuthException catch (e) {
                          if (e.code ==
                              LocalAuthExceptionCode.noCredentialsSet) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content: Text(
                                    'Set a screen lock to the device to use this feature.')));
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                margin: const EdgeInsets.all(6),
                                behavior: SnackBarBehavior.floating,
                                showCloseIcon: true,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                content:
                                    Text('Failed to lock entry: ${e.code}')));
                          }
                        }
                      }
                    },
                  ),
                // Option to export the note as a plain text
                BloomModalListTile(
                  leadingIcon: Icon(Icons.text_snippet),
                  title: 'Share as Plain Text',
                  onTap: () {
                    SharePlus.instance.share(ShareParams(
                        title: widget.titleController.text,
                        subject:
                            "${userName!.isEmpty ? email!.substring(0, 8) : userName} shared with you",
                        text: widget.controller.document.toPlainText()));
                    // PDFConverter(
                    //   params: PDFPageFormat.a4,
                    //   document: widget.controller.document.toDelta(),
                    //   frontMatterDelta: null,
                    //   backMatterDelta: null,
                    //   customConverters: [],
                    //   onRequestBoldFont: (p0) {
                    //     final loader = FontLoader('Nunito');
                    //     loader. ;
                    //     return FontLoader('Nunito').load('');
                    //   },
                    //   onRequestBoldItalicFont: (p0) {},
                    //   onRequestFallbackFont: (p0) {},
                    //   onRequestFont: (p0) {},
                    //   onRequestItalicFont: (p0) {},
                    //   fallbacks: [],
                    // );
                  },
                ),
                // Delete entry option shown only if there is entryId
                if (widget.entryId.isNotEmpty)
                  BloomModalListTile(
                    leadingIcon: Icon(Icons.delete_rounded,
                        color: Theme.of(context).colorScheme.error),
                    title: 'Delete entry',
                    titleStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).colorScheme.error),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text('Succesfully deleted entry'),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                width: double.maxFinite,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Syncing status: ${widget.syncingStatus! ? 'Syncing' : 'Synced'}'),
                    Text('Character count: ${widget.numberOfWords}'),
                    Text('Last edited by: You'),
                    Text(
                        'On: ${DateFormat('dd, LLL yyyy').format(widget.dateTime)} at ${DateFormat('h:mm a').format(widget.dateTime)}')
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 28,
            ),
          ],
        ),
      ),
    );
  }
}
