import 'package:bloom/authentication_screens/lock_object_method.dart';
import 'package:bloom/models/book_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookCard extends StatefulWidget {
  final String? bookId;
  final String? type;
  final String? entryId;
  final String? emoji;
  final String? title;
  final String? description;
  final DateTime dateTime;
  final List<String>? tags;
  final List? attachments;
  final List? children;
  final bool? hasChildren;
  final Function()? onTap;
  final bool isTemplate;
  final EdgeInsetsGeometry? innerPadding;
  final bool isBookLocked;
  const BookCard(
      {super.key,
      this.emoji,
      this.title,
      this.type,
      this.description,
      required this.dateTime,
      this.tags,
      this.hasChildren,
      this.attachments,
      this.onTap,
      this.bookId,
      this.entryId,
      required this.isTemplate,
      this.innerPadding,
      this.children,
      required this.isBookLocked});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: InkWell(
        onTap: widget.onTap ??
            () async {
              if (widget.isBookLocked) {
                final bool isAuthenticated = await checkForBiometrics(
                    'Please authenticate to open this entry', context);
                if (isAuthenticated) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BookLayout(
                          type: widget.type ?? 'book',
                          bookId: widget.bookId,
                          emoji: widget.emoji,
                          dateTime: widget.dateTime,
                          title: widget.title,
                          description: widget.description,
                          bookLayoutMethod: BookLayoutMethod.edit,
                          children: widget.children ?? [],
                          hasChildren: widget.hasChildren ?? false,
                          isFirstTime: false,
                          isTemplate: widget.isTemplate,
                          isFavorite: false)));
                }
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BookLayout(
                        type: widget.type ?? 'book',
                        bookId: widget.bookId,
                        emoji: widget.emoji,
                        dateTime: widget.dateTime,
                        title: widget.title,
                        description: widget.description,
                        bookLayoutMethod: BookLayoutMethod.edit,
                        children: widget.children ?? [],
                        hasChildren: widget.hasChildren ?? false,
                        isFirstTime: false,
                        isTemplate: widget.isTemplate,
                        isFavorite: false)));
              }
            },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: widget.innerPadding ?? const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.emoji ?? '',
                style: const TextStyle(fontSize: 28),
              ),
              const Spacer(),
              Text(
                widget.title ?? 'Untitled',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              if (widget.tags != null)
                widget.tags!.length >= 3
                    ? Text(" ${widget.tags!.first}... ")
                    : Text(" ${widget.tags!.join(', ')}"),
              Text(
                DateFormat('dd-MM, h:mm a').format(widget.dateTime),
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
