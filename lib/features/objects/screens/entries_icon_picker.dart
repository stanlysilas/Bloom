import 'package:bloom/core/responsive/dimensions.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EntriesIconPicker extends StatefulWidget {
  final String icon;
  const EntriesIconPicker({super.key, required this.icon});

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
          IconButton(
              tooltip: 'Remove icon',
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.errorContainer)),
              onPressed: () {
                Navigator.pop(context, '');
              },
              icon: Icon(Icons.delete,
                  color: Theme.of(context).colorScheme.onErrorContainer))
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width > mobileWidth ? 650 : null,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: EmojiPicker(
                      textEditingController: searchEmojisController,
                      config: Config(
                        checkPlatformCompatibility: true,
                        emojiTextStyle: TextStyle(
                            fontFamily: 'Nunito',
                            // fontFamilyFallback: ['AppleEmoji']
                            ),
                        emojiViewConfig: EmojiViewConfig(
                            noRecents:
                                Text('Recently selected emojis appear here'),
                            replaceEmojiOnLimitExceed: true,
                            columns: 8,
                            verticalSpacing: 4,
                            horizontalSpacing: 4,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface),
                        viewOrderConfig: const ViewOrderConfig(
                          top: EmojiPickerItem.searchBar,
                          middle: EmojiPickerItem.emojiView,
                          bottom: EmojiPickerItem.categoryBar,
                        ),
                        searchViewConfig: SearchViewConfig(
                            hintText: 'Search',
                            buttonIconColor:
                                Theme.of(context).colorScheme.onSurface,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface),
                        categoryViewConfig: CategoryViewConfig(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                            iconColorSelected:
                                Theme.of(context).colorScheme.primary),
                        bottomActionBarConfig: BottomActionBarConfig(
                            showBackspaceButton: false,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainer,
                            buttonColor: Theme.of(context).colorScheme.primary),
                      ),
                      onEmojiSelected: (category, emoji) {
                        Navigator.pop(context, emoji.emoji);
                      },
                    ),
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
