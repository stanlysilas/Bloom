import 'package:bloom/models/book_layout.dart';
import 'package:bloom/theme/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomTemplatesCard extends StatefulWidget {
  final String templateId;
  final String templateType;
  final String templateThumbnail;
  final String templateThumbnailDark;
  final String templateIcon;
  final String templateTitle;
  final String templateDescription;
  final List templateChildren;
  final DateTime dateOfCreation;
  final String createdBy;
  const CustomTemplatesCard(
      {super.key,
      required this.templateId,
      required this.templateType,
      required this.templateIcon,
      required this.templateTitle,
      required this.templateDescription,
      required this.dateOfCreation,
      required this.createdBy,
      required this.templateChildren,
      required this.templateThumbnail,
      required this.templateThumbnailDark});

  @override
  State<CustomTemplatesCard> createState() => _CustomTemplatesCardState();
}

class _CustomTemplatesCardState extends State<CustomTemplatesCard> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (widget.templateType == 'book') {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BookLayout(
                      isTemplate: true,
                      type: widget.templateType,
                      dateTime: widget.dateOfCreation,
                      emoji: widget.templateIcon,
                      title: widget.templateTitle,
                      description: widget.templateDescription,
                      bookLayoutMethod: BookLayoutMethod.display,
                      children: widget.templateChildren,
                      bookId: widget.templateId,
                      // Below settings are true for debugging purposes only
                      hasChildren: true,
                      isFavorite: true)));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Image of the template
                ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl:
                          themeProvider.themeData.brightness == Brightness.dark
                              ? widget.templateThumbnailDark
                              : widget.templateThumbnail,
                      fit: BoxFit.fitWidth,
                    )),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title of the template
                      Text(
                        widget.templateTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      // Description of the template
                      Text(widget.templateDescription),
                      const SizedBox(
                        height: 8,
                      ),
                      // Date of creation and created by user name
                      Text(
                          "Created on: ${DateFormat('LLL, yyyy').format(widget.dateOfCreation)} by: ${widget.createdBy}",
                          style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
