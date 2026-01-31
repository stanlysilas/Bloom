import 'package:bloom/models/note_layout.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EntriesIconPicker extends StatefulWidget {
  final String icon;
  final EmojiNotifier iconNotifier;
  final String from;
  const EntriesIconPicker(
      {super.key,
      required this.icon,
      required this.iconNotifier,
      required this.from});

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
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.grey)),
        title: Text('Select Icon',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
        actions: [
          widget.iconNotifier.emoji == '' || widget.iconNotifier.emoji == null
              ? const SizedBox()
              : IconButton(
                  tooltip: 'Remove icon',
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.errorContainer)),
                  onPressed: () {
                    widget.iconNotifier.emoji = '';
                    if (widget.from == 'more') {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: EmojiPicker(
                  textEditingController: searchEmojisController,
                  config: Config(
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                        noRecents: Text('Recently selected emojis appear here'),
                        replaceEmojiOnLimitExceed: true,
                        columns: 8,
                        verticalSpacing: 4,
                        horizontalSpacing: 4,
                        backgroundColor: Theme.of(context).colorScheme.surface),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.searchBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.categoryBar,
                    ),
                    searchViewConfig: SearchViewConfig(
                        hintText: 'Search',
                        buttonIconColor:
                            Theme.of(context).colorScheme.onSurface,
                        backgroundColor: Theme.of(context).colorScheme.surface),
                    categoryViewConfig: CategoryViewConfig(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        iconColorSelected:
                            Theme.of(context).colorScheme.primary),
                    bottomActionBarConfig: BottomActionBarConfig(
                        showBackspaceButton: false,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        buttonColor: Theme.of(context).colorScheme.primary),
                  ),
                  onEmojiSelected: (category, emojiString) {
                    widget.iconNotifier.emoji = emojiString.emoji;
                    if (widget.from == 'more') {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
