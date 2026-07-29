import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/features/auth/authenticate_object.dart';
import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/objects/screens/entries_background_images.dart';
import 'package:bloom/features/objects/screens/entries_icon_picker.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/models/user_model.dart';
import 'package:bloom/services/firebase/parent_object_service.dart';
import 'package:bloom/services/firebase/object_service.dart';
import 'package:bloom/services/firebase/user_profile_service.dart';
import 'package:bloom/services/permissions/bloom_pin_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreEntryOptions extends StatefulWidget {
  final BloomObjectModel bloomObject;
  final int? characterCount;
  const MoreEntryOptions({
    super.key,
    required this.bloomObject,
    this.characterCount,
  });

  @override
  State<MoreEntryOptions> createState() => _MoreEntryOptionsState();
}

class _MoreEntryOptionsState extends State<MoreEntryOptions> {
  final pinService = BloomPinService();
  final profileService = UserProfileService();
  final objectService = ObjectService();
  final parentObjectService = ParentObjectService();
  UserModel? userModel;
  final bloomSnackBars = BloomSnackBars();
  final user = FirebaseAuth.instance.currentUser;
  bool? isLocked;
  bool? isPrivacyPasswordSet;
  late BloomObjectModel bloomObject;

  @override
  void initState() {
    super.initState();
    bloomObject = widget.bloomObject;
    loadUserDetails();
    checkSharedPreferencesIfLocked();
  }

  Future<void> loadUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final result = await profileService.getUserDetails(uid);

    if (!mounted) return;

    setState(() {
      userModel = result;
    });
  }

  Future<void> checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(bloomObject.objectId!) ?? bloomObject.isLocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = userModel?.userName.isNotEmpty == true
        ? userModel!.userName
        : (userModel?.email.substring(0, 8) ?? "Bloom user");

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BloomModalListTile(
                leadingIcon: bloomObject.icon.isEmpty
                    ? Icon(Icons.emoji_emotions_outlined)
                    : Text(
                        bloomObject.icon,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                title: 'Change icon',
                onTap: () async {
                  final newIcon = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => EntriesIconPicker(
                        icon: bloomObject.icon,
                      ),
                    ),
                  );

                  if (newIcon != null) {
                    final updatedObject = bloomObject.copyWith(icon: newIcon);
                    Navigator.pop(context, updatedObject);
                  }
                }),
            BloomModalListTile(
              leadingIcon: Icon(Icons.image_outlined),
              title: 'Change background',
              onTap: () async {
                final newBackgroundImageUrl =
                    await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => EntriesBackgroundImages(
                            backgroundImageUrl: bloomObject.backgroundImageUrl,
                          )),
                );
                if (newBackgroundImageUrl != null) {
                  final updatedObject = bloomObject.copyWith(
                      backgroundImageUrl: newBackgroundImageUrl);
                  Navigator.pop(context, updatedObject);
                }
              },
            ),
            if (bloomObject.objectId!.isNotEmpty)
              BloomModalListTile(
                title: 'Lock this entry',
                leadingIcon: Icon(Icons.lock_rounded),
                onTap: () async {},
                trailing: Switch(
                    value: isLocked ?? false,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      final useBloomPin = prefs.getBool('useBloomPin') ?? false;
                      final bool isAuthenticated = await authenticate(
                          'Confirm authentication of this object', context);
                      try {
                        if (useBloomPin) {
                          // TODO: ADD FUNCTIONALITY TO AUTHENTICATE WITH ONLY BLOOM PIN
                        } else {
                          if (isAuthenticated) {
                            setState(() {
                              isLocked = value;
                            });
                            if (bloomObject.type == 'book') {
                              parentObjectService.updateBookObjectLockState(
                                  widget.bloomObject.parentId!,
                                  widget.bloomObject.objectId!,
                                  value);
                            } else {
                              objectService.updateLockState(
                                  widget.bloomObject.objectId!, value);
                            }
                            prefs.setBool(widget.bloomObject.objectId!, value);
                            bloomSnackBars.showSuccessSnackBar(value
                                ? "Entry successfully locked"
                                : "Entry successfully unlocked");
                          }
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        bloomSnackBars.showGenericErrorSnackBar(
                            context, e.toString());
                      }
                    }),
              ),

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
            BloomModalListTile(
              leadingIcon: Icon(Icons.text_snippet),
              title: 'Share as Plain Text',
              onTap: () {
                SharePlus.instance.share(ShareParams(
                    title: widget.bloomObject.title,
                    subject: "$displayName shared with you",
                    text: widget.bloomObject.content));
              },
            ),
            if (widget.bloomObject.objectId!.isNotEmpty)
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
                    bloomSnackBars.showGenericErrorSnackBar(
                        context, 'Unlock the entry to delete it.');
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return DeleteConfirmationDialog(
                              onPressed: () async {
                                if (widget.bloomObject.type == 'book') {
                                  parentObjectService.deleteBookObject(
                                      widget.bloomObject.parentId!,
                                      widget.bloomObject.objectId!);
                                } else {
                                  objectService
                                      .deleteObject(widget.bloomObject);
                                }
                                Navigator.pop(context);
                                Navigator.pop(context);
                                bloomSnackBars.showSuccessSnackBar(
                                    'Succesfully deleted entry');
                                Navigator.pop(context);
                              },
                              objectName: widget.bloomObject.title);
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
                      'Syncing status: ${widget.bloomObject.isSyncing ? 'Syncing' : 'Synced'}'),
                  Text('Character count: ${widget.characterCount}'),
                  Text('Last edited by: You'),
                  Text(
                      'On: ${DateFormat('dd, LLL yyyy').format(widget.bloomObject.dateTime)} at ${DateFormat('h:mm a').format(widget.bloomObject.dateTime)}')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
