import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/utils/object_router.dart';
import 'package:bloom/core/utils/quill_delta_to_rich_text.dart';
import 'package:bloom/features/auth/authenticate_object.dart';
import 'package:bloom/core/widgets/delete_confirmation_dialog.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/services/firebase/parent_object_service.dart';
import 'package:bloom/services/firebase/object_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class ObjectsTile extends StatefulWidget {
  final EdgeInsetsGeometry? innerPadding;
  final BoxDecoration? decoration;
  final BorderRadius? borderRadius;
  final BloomObjectModel bloomObject;
  const ObjectsTile({
    super.key,
    this.innerPadding,
    this.decoration,
    this.borderRadius,
    required this.bloomObject,
  });

  @override
  State<ObjectsTile> createState() => _ObjectsTileState();
}

class _ObjectsTileState extends State<ObjectsTile> {
  final bloomSnackBars = BloomSnackBars();
  final objectService = ObjectService();
  final parentObjectService = ParentObjectService();
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.bloomObject.isFavorite;
  }

  Widget descriptionText(BuildContext context, String? title, String content) {
    return widget.bloomObject.type == 'note'
        ? quillDeltaToRichText(context, title, content)
        : Text(content, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  isFavorite = !isFavorite;
                });
                debugPrint('isFavorite: $isFavorite');
                await objectService.updateObject(widget.bloomObject.copyWith(
                    isFavorite: isFavorite, dateTime: DateTime.now()));
                bloomSnackBars.showSuccessSnackBar(isFavorite
                    ? "Added to favorites"
                    : "Removed from favorites");
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
                if (widget.bloomObject.isLocked == true) {
                  bloomSnackBars.showGenericErrorSnackBar(
                      context, 'Unlock the entry to delete it!');
                } else {
                  showAdaptiveDialog(
                      context: context,
                      builder: (context) {
                        return DeleteConfirmationDialog(
                            onPressed: () {
                              Navigator.of(context).pop();

                              objectService.deleteObject(widget.bloomObject);
                              bloomSnackBars.showSuccessSnackBar(
                                  'Deleted ${widget.bloomObject.title}');
                            },
                            objectName: widget.bloomObject.title);
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
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      child: Material(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
        child: InkWell(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
          onTap: () async {
            if (widget.bloomObject.isLocked) {
              final bool isAuthenticated = await authenticate(
                  'Please authenticate to open this entry', context);
              if (isAuthenticated) {
                await ObjectRouter.open(
                    context, widget.bloomObject.copyWith(isSyncing: false));
              }
            } else {
              await ObjectRouter.open(
                  context, widget.bloomObject.copyWith(isSyncing: false));
            }
          },
          child: Container(
            decoration: widget.decoration ?? BoxDecoration(),
            padding: widget.innerPadding ?? const EdgeInsets.all(0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 6,
              children: [
                widget.bloomObject.icon.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                        child: widget.bloomObject.isLocked
                            ? Icon(
                                Icons.lock_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              )
                            : Text(
                                widget.bloomObject.icon,
                                style: TextStyle(fontSize: 18),
                              ))
                    : Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                        child: widget.bloomObject.isLocked
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
                        widget.bloomObject.title.isEmpty
                            ? 'Untitled'
                            : widget.bloomObject.title,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500),
                      ),
                      descriptionText(context, widget.bloomObject.title,
                          widget.bloomObject.content),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.MEd().format(widget.bloomObject.addedOn),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('h:mm a').format(widget.bloomObject.addedOn),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
