import 'package:bloom/core/utils/bloom_snackbars.dart';
import 'package:bloom/core/utils/object_router.dart';
import 'package:bloom/features/auth/authenticate_object.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookCard extends StatefulWidget {
  final EdgeInsetsGeometry? innerPadding;
  final BloomObjectModel bookModel;
  const BookCard({
    super.key,
    this.innerPadding,
    required this.bookModel,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final bloomSnackBars = BloomSnackBars();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        onTap: () async {
          try {
            if (widget.bookModel.isLocked) {
              final bool isAuthenticated = await authenticate(
                  'Please authenticate to open this entry', context);
              if (isAuthenticated) {
                ObjectRouter.open(context, widget.bookModel);
              }
            } else {
              ObjectRouter.open(context, widget.bookModel);
            }
          } catch (e) {
            bloomSnackBars.showGenericErrorSnackBar(context, e.toString());
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.bookModel.isLocked
                  ? Icon(Icons.lock,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)
                  : Text(
                      widget.bookModel.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
              Text(
                widget.bookModel.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              // if (widget.bookModel.tags.isEmpty)
              //   widget.bookModel.tags.length >= 3
              //       ? Text(" ${widget.bookModel.tags.first}... ")
              //       : Text(" ${widget.bookModel.tags.join(', ')}"),
              Text(
                DateFormat('dd-MM, h:mm a').format(widget.bookModel.dateTime),
                maxLines: 1,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
