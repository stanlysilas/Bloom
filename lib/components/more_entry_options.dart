// ignore_for_file: must_be_immutable

import 'package:bloom/authentication_screens/authenticate_object.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/delete_confirmation_dialog.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/screens/entries_background_images.dart';
import 'package:bloom/screens/entries_icon_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
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
  bool? isPrivacyPasswordSet;
  @override
  void initState() {
    super.initState();
    checkSharedPreferencesIfLocked();
    fetchAccountData();
    privacyPasswordCheck();
  }

  /// Check the Privacy Password status
  void privacyPasswordCheck() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('security')
          .doc('bloomPin')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final enabled = data?['enabled'];

        setState(() {
          if ((enabled != null && enabled == true)) {
            isPrivacyPasswordSet = true;
          } else {
            isPrivacyPasswordSet = false;
          }
        });
      }
    } catch (e) {
      //
    }
  }

  Future<void> checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(widget.entryId) ?? widget.isEntryLocked;
    });
  }

  /// Call this where you need the dialog
  /// final result = await showAddCollaboratorDialog(context);
  /// if (result != null) { use result['email'] and result['permission']; }
  Future<Map<String, String>?> showAddCollaboratorDialog() {
    final TextEditingController emailController = TextEditingController();
    String permission = 'view'; // 'view' | 'edit'

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Add Collaborator',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Email field
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Permission dropdown
                  DropdownButtonFormField<String>(
                    initialValue: permission,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'view',
                        child: Text('View only'),
                      ),
                      DropdownMenuItem(
                        value: 'edit',
                        child: Text('View & edit'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        permission = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          final email = emailController.text.trim();
                          if (email.isEmpty) return;
                          Navigator.of(context).pop({
                            'email': email,
                            'permission': permission,
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<String?> addCollaborator({
    required String noteId,
    required String collaboratorEmail,
    required String permission, // "owner" | "edit" | "view"
  }) async {
    try {
      // 1️⃣ Lookup UID via email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: collaboratorEmail.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return "User not found!";
      }

      final collaboratorUid = querySnapshot.docs.first.id;

      // 2️⃣ Build field path in collaborators map
      String field;
      switch (permission) {
        case 'owner':
          field = 'collaborators.owners';
          break;
        case 'edit':
          field = 'collaborators.editors';
          break;
        default:
          field = 'collaborators.viewers';
      }

      // 3️⃣ Push UID into correct array (no duplicates)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid) // your user folder
          .collection('entries')
          .doc(noteId)
          .update({
        field: FieldValue.arrayUnion([collaboratorUid])
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                          from: 'more',
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
                            from: 'more',
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
                title:
                    isLocked == true ? 'Unlock this entry' : 'Lock this entry',
                leadingIcon: Icon(isLocked == true
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final useBloomPin = prefs.getBool('useBloomPin') ?? false;
                  final bool isAuthenticated = await authenticate(
                      'Confirm authentication of this object', context);
                  // First check if the entry is locked or unlocked
                  try {
                    if (useBloomPin) {
                      // TODO: ADD FUNCTIONALITY TO AUTHENTICATE WITH ONLY BLOOM PIN
                    } else {
                      if (isLocked == true) {
                        // Unlock the entry if [isAuthenticated] returns true
                        if (isAuthenticated) {
                          setState(() {
                            isLocked = false;
                          });
                          // Update [FirebaseFirestore] with the new authentication state for the object
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
                          // Show a confirmation for the user
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              margin: const EdgeInsets.all(6),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text('Entry Unlocked')));
                          // Close the modal sheet after authenticating
                          Navigator.of(context).pop();
                        } else {
                          // User did not authenticate or the authentication failed
                        }
                      } else {
                        // The object is not locked, we need to lock it now after authentication
                        // Lock the entry if [isAuthenticated] returns true
                        if (isAuthenticated) {
                          // Change the local state to locked
                          setState(() {
                            isLocked = true;
                          });
                          // Update [FirebaseFirestore] with the new authentication state for the object
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
                          // Show a confirmation for the user
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              margin: const EdgeInsets.all(6),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text('Entry Locked')));
                          // Close the modal sheet after authenticating
                          Navigator.of(context).pop();
                        } else {
                          // User did not authenticate or the authentication failed
                        }
                      }
                    }
                  } catch (e) {
                    print(e.toString());
                  }
                  // final LocalAuthentication auth = LocalAuthentication();
                  // final bool canAuthenticateWithBiometrics =
                  //     await auth.canCheckBiometrics;
                  // final bool canAuthenticate = canAuthenticateWithBiometrics ||
                  //     await auth.isDeviceSupported();
                  // final prefs = await SharedPreferences.getInstance();
                  // if (canAuthenticate) {
                  //   try {
                  //     if (isLocked == true) {
                  //       // Try authenticating first
                  //       await auth.authenticate(
                  //           localizedReason:
                  //               'Confirm authentication of this object');
                  //       // Set false if its already locked
                  //       // Logic to unlock the entry
                  //       setState(() {
                  //         isLocked = false;
                  //       });
                  //       if (widget.type == 'note') {
                  //         prefs.setBool(widget.entryId, isLocked ?? false);
                  //         await FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(user?.uid)
                  //             .collection('entries')
                  //             .doc(widget.entryId)
                  //             .update({
                  //           'isEntryLocked': isLocked,
                  //         });
                  //       } else if (widget.type == 'book') {
                  //         prefs.setBool(widget.entryId, isLocked ?? false);
                  //         await FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(user?.uid)
                  //             .collection('books')
                  //             .doc(widget.mainId)
                  //             .collection('pages')
                  //             .doc(widget.entryId)
                  //             .update({
                  //           'isEntryLocked': isLocked,
                  //         });
                  //       }
                  //       // Go back to entries screen
                  //       Navigator.pop(context);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           margin: const EdgeInsets.all(6),
                  //           behavior: SnackBarBehavior.floating,
                  //           showCloseIcon: true,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           content: Text('Entry Unlocked')));
                  //     } else {
                  //       // Try authenticating first
                  //       await auth.authenticate(
                  //           localizedReason:
                  //               'Confirm authentication of this object');
                  //       // Set true and lock if not locked
                  //       // Logic to lock the entry
                  //       setState(() {
                  //         isLocked = true;
                  //       });
                  //       if (widget.type == 'note') {
                  //         prefs.setBool(widget.entryId, isLocked ?? true);
                  //         await FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(user?.uid)
                  //             .collection('entries')
                  //             .doc(widget.entryId)
                  //             .update({
                  //           'isEntryLocked': isLocked,
                  //         });
                  //       } else if (widget.type == 'book') {
                  //         prefs.setBool(widget.entryId, isLocked ?? true);
                  //         await FirebaseFirestore.instance
                  //             .collection('users')
                  //             .doc(user?.uid)
                  //             .collection('books')
                  //             .doc(widget.mainId)
                  //             .collection('pages')
                  //             .doc(widget.entryId)
                  //             .update({
                  //           'isEntryLocked': isLocked,
                  //         });
                  //       }
                  //       Navigator.pop(context);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           margin: const EdgeInsets.all(6),
                  //           behavior: SnackBarBehavior.floating,
                  //           showCloseIcon: true,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           content: Text('Entry Locked')));
                  //     }
                  //   } on PlatformException catch (e) {
                  //     //
                  //     if (e.code == 'NotAvailable') {
                  //       Navigator.pop(context);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           margin: const EdgeInsets.all(6),
                  //           behavior: SnackBarBehavior.floating,
                  //           showCloseIcon: true,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           content: Text(
                  //               'Set a screen lock to the device to use this feature.')));
                  //     } else {
                  //       Navigator.pop(context);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           margin: const EdgeInsets.all(6),
                  //           behavior: SnackBarBehavior.floating,
                  //           showCloseIcon: true,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           content: Text('Failed to lock entry: ${e.code}')));
                  //     }
                  //   } on LocalAuthException catch (e) {
                  //     if (e.code == LocalAuthExceptionCode.noCredentialsSet) {
                  //       // TODO: ADD THE PRIVACY PASSWORD OPTION
                  //       if (isLocked == false && isPrivacyPasswordSet == true) {
                  //         final authenticated = await Navigator.push<bool>(
                  //           context,
                  //           MaterialPageRoute(
                  //             fullscreenDialog: true,
                  //             builder: (_) => const PasswordEntryScreen(
                  //               mode: PinMode.verify,
                  //               message: 'Verify your Privacy PIN to lock',
                  //             ),
                  //           ),
                  //         );
                  //         if (authenticated == true) {
                  //           // Set true and lock if not locked
                  //           // Logic to lock the entry
                  //           setState(() {
                  //             isLocked = true;
                  //           });
                  //           if (widget.type == 'note') {
                  //             prefs.setBool(widget.entryId, isLocked ?? true);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('entries')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           } else if (widget.type == 'book') {
                  //             prefs.setBool(widget.entryId, isLocked ?? true);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('books')
                  //                 .doc(widget.mainId)
                  //                 .collection('pages')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           }
                  //           Navigator.pop(context);
                  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //               margin: const EdgeInsets.all(6),
                  //               behavior: SnackBarBehavior.floating,
                  //               showCloseIcon: true,
                  //               shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(12)),
                  //               content: Text('Entry Locked')));
                  //         }
                  //       } else if (isLocked == true &&
                  //           isPrivacyPasswordSet == true) {
                  //         final authenticated = await Navigator.push<bool>(
                  //           context,
                  //           MaterialPageRoute(
                  //             fullscreenDialog: true,
                  //             builder: (_) => const PasswordEntryScreen(
                  //               mode: PinMode.verify,
                  //               message: 'Verify your Privacy PIN to unlock',
                  //             ),
                  //           ),
                  //         );
                  //         if (authenticated == true) {
                  //           // Set true and lock if not locked
                  //           // Logic to lock the entry
                  //           setState(() {
                  //             isLocked = false;
                  //           });
                  //           if (widget.type == 'note') {
                  //             prefs.setBool(widget.entryId, isLocked ?? false);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('entries')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           } else if (widget.type == 'book') {
                  //             prefs.setBool(widget.entryId, isLocked ?? false);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('books')
                  //                 .doc(widget.mainId)
                  //                 .collection('pages')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           }
                  //           Navigator.pop(context);
                  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //               margin: const EdgeInsets.all(6),
                  //               behavior: SnackBarBehavior.floating,
                  //               showCloseIcon: true,
                  //               shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(12)),
                  //               content: Text('Entry Unlocked')));
                  //         }
                  //       } else {
                  //         final authenticated = await Navigator.push<bool>(
                  //           context,
                  //           MaterialPageRoute(
                  //             fullscreenDialog: true,
                  //             builder: (_) => const PasswordEntryScreen(
                  //               mode: PinMode.verify,
                  //               message: 'Verify your Privacy PIN to lock',
                  //             ),
                  //           ),
                  //         );
                  //         if (authenticated == true) {
                  //           // Set true and lock if not locked
                  //           // Logic to lock the entry
                  //           setState(() {
                  //             isLocked = true;
                  //           });
                  //           if (widget.type == 'note') {
                  //             prefs.setBool(widget.entryId, isLocked ?? true);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('entries')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           } else if (widget.type == 'book') {
                  //             prefs.setBool(widget.entryId, isLocked ?? true);
                  //             await FirebaseFirestore.instance
                  //                 .collection('users')
                  //                 .doc(user?.uid)
                  //                 .collection('books')
                  //                 .doc(widget.mainId)
                  //                 .collection('pages')
                  //                 .doc(widget.entryId)
                  //                 .update({
                  //               'isEntryLocked': isLocked,
                  //             });
                  //           }
                  //           Navigator.pop(context);
                  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //               margin: const EdgeInsets.all(6),
                  //               behavior: SnackBarBehavior.floating,
                  //               showCloseIcon: true,
                  //               shape: RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(12)),
                  //               content: Text('Entry Locked')));
                  //         }
                  //       }
                  //     } else {
                  //       Navigator.pop(context);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //           margin: const EdgeInsets.all(6),
                  //           behavior: SnackBarBehavior.floating,
                  //           showCloseIcon: true,
                  //           shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12)),
                  //           content: Text('Failed to lock entry: ${e.code}')));
                  //     }
                  //   }
                  // }
                },
              ),
            // Add Collaborator option
            /// TODO: CREATE THE ARCHITECTURE AND LOGIC FOR IMPLEMENTING COLLABORATION PROPERLY
            // BloomModalListTile(
            //   leadingIcon: Icon(Icons.person_add),
            //   title: 'Add Collaborator',
            //   onTap: () async {
            //     final result = await showAddCollaboratorDialog();
            //     final collaboratorEmail = result!['email'];
            //     final permission = result['permission'];

            //     // Add the Collaborator to the note in Database
            //     final data = await addCollaborator(
            //       noteId: widget.entryId,
            //       collaboratorEmail: collaboratorEmail!,
            //       permission: permission!,
            //     );

            //     if (data != null) {
            //       print("Error: $data");
            //     } else {
            //       print("Collaborator added successfully!");
            //     }
            //   },
            // ),
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
                leadingDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.errorContainer),
                leadingIcon: Icon(Icons.delete_rounded,
                    color: Theme.of(context).colorScheme.onErrorContainer),
                title: 'Delete entry',
                titleStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                    color: Theme.of(context).colorScheme.error),
                onTap: () {
                  if (isLocked == true) {
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
                    showDialog(
                        context: context,
                        builder: (context) {
                          return DeleteConfirmationDialog(
                              onPressed: () async {
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
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text('Succesfully deleted entry'),
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              objectName: widget.titleController.text);
                        });
                  }
                },
              ),
            const SizedBox(height: 56),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
          ],
        ),
      ),
    );
  }
}
