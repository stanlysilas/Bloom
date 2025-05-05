import 'package:bloom/models/note_layout.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EntriesIconPicker extends StatefulWidget {
  final String icon;
  final EmojiNotifier iconNotifier;
  const EntriesIconPicker(
      {super.key, required this.icon, required this.iconNotifier});

  @override
  State<EntriesIconPicker> createState() => _EntriesIconPickerState();
}

class _EntriesIconPickerState extends State<EntriesIconPicker> {
  late TextEditingController searchEmojisController;

  @override
  void initState() {
    super.initState();
    searchEmojisController = TextEditingController(text: widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          widget.iconNotifier.emoji == '' || widget.iconNotifier.emoji == null
              ? const SizedBox()
              : IconButton(
                  onPressed: () {
                    widget.iconNotifier.emoji = '';
                    Navigator.pop(context);
                  },
                  icon: const Text(
                    'Remove',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: EmojiPicker(
                textEditingController: searchEmojisController,
                config: Config(
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    noRecents: Text('Recently selected emojis appear here',
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color)),
                    replaceEmojiOnLimitExceed: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    columns: 8,
                    verticalSpacing: 4,
                    horizontalSpacing: 4,
                  ),
                  viewOrderConfig: const ViewOrderConfig(
                    top: EmojiPickerItem.searchBar,
                    middle: EmojiPickerItem.emojiView,
                    bottom: EmojiPickerItem.categoryBar,
                  ),
                  searchViewConfig: SearchViewConfig(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      hintText: 'Search',
                      buttonIconColor: Theme.of(context).iconTheme.color!),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    iconColorSelected: Theme.of(context).primaryColor,
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                      showBackspaceButton: false,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      buttonColor: Theme.of(context).primaryColorLight,
                      buttonIconColor: Theme.of(context).iconTheme.color!),
                ),
                onEmojiSelected: (category, emojiString) {
                  widget.iconNotifier.emoji = emojiString.emoji;
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
