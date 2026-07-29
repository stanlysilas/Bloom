import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/widgets/bloom_buttons.dart';
import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/features/auth/authenticate_object.dart';
import 'package:bloom/services/firebase/parent_object_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookMoreOptionsModalSheet extends StatefulWidget {
  const BookMoreOptionsModalSheet({super.key});

  @override
  State<BookMoreOptionsModalSheet> createState() =>
      _BookMoreOptionsModalSheetState();
}

class _BookMoreOptionsModalSheetState extends State<BookMoreOptionsModalSheet> {
  bool? isLocked;
  final parentObjectService = ParentObjectService();
  final bloomSnackBars = BloomSnackBars();

  @override
  void initState() {
    super.initState();
    checkSharedPreferencesIfLocked();
  }

  Future<bool> checkSharedPreferencesIfLocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool(bookModel.objectId!) ?? bookModel.isLocked;
    });
    return isLocked!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(
            height: 14,
          ),
          if (bookModel.objectId!.isNotEmpty)
            BloomModalListTile(
              title: isLocked == true
                  ? 'Unlock ${bookModel.title}'
                  : 'Lock ${bookModel.title}',
              leadingIcon: Icon(
                  isLocked == true
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final useBloomPin = prefs.getBool('useBloomPin') ?? false;
                final bool isAuthenticated = await authenticate(
                    'Confirm authentication of this object', context);
                try {
                  if (useBloomPin) {
                    // TODO: ADD FUNCTIONALITY TO AUTHENTICATE WITH ONLY BLOOM PIN
                  } else {
                    if (isLocked == true) {
                      if (isAuthenticated) {
                        setState(() {
                          isLocked = false;
                        });
                        prefs.setBool(bookModel.objectId!, isLocked ?? false);
                        parentObjectService.updateBookLockState(
                            bookModel.objectId!, isLocked!);
                        bloomSnackBars.showSuccessSnackBar("Book Unlocked");
                        Navigator.of(context).pop();
                      } else {}
                    } else {
                      if (isAuthenticated) {
                        setState(() {
                          isLocked = true;
                        });
                        prefs.setBool(bookModel.objectId!, isLocked ?? true);
                        parentObjectService.updateBookLockState(
                            bookModel.objectId!, isLocked!);
                        bloomSnackBars.showSuccessSnackBar("Book Locked");
                        Navigator.of(context).pop();
                      } else {}
                    }
                  }
                } catch (e) {
                  bloomSnackBars.showGenericErrorSnackBar(
                      context, e.toString());
                }
              },
            ),
          if (bookModel.objectId!.isNotEmpty)
            BloomModalListTile(
              leadingDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.errorContainer),
              leadingIcon: Icon(Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer),
              title: 'Delete ${bookModel.title}',
              titleStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.error),
              onTap: () {
                if (bookModel.isLocked == true) {
                  bloomSnackBars.showGenericErrorSnackBar(
                      context, 'Unlock the book to delete it!');
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmationDialog(
                            onPressed: () async {
                              parentObjectService
                                  .deleteBook(bookModel.objectId!);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              bloomSnackBars.showSuccessSnackBar(
                                  "Book deleted succesfully");
                              Navigator.of(context).pop();
                            },
                            objectName: bookModel.title);
                      });
                }
              },
            ),
        ],
      ),
    );
  }
}
