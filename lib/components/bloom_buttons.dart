import 'dart:math';

import 'package:bloom/components/add_event.dart';
// import 'package:bloom/components/add_pomodoro.dart';
import 'package:bloom/components/add_taskorhabit.dart';
import 'package:bloom/models/book_layout.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TypesOfObjects extends StatefulWidget {
  /// Display all types of objects in a [ListTile] with Bloom's style.
  const TypesOfObjects({
    super.key,
  });

  @override
  State<TypesOfObjects> createState() => _TypesOfObjectsState();
}

List typesOfEntries = [
  'Task', 'Habit', 'Event', 'Note',
  // 'Pomodoro',
  'Book',
  //  'Habit',
// 'Book', 'Page', 'Collection'
];
List iconsForTypesOfEntries = [
  Icons.task_alt_rounded,
  Icons.self_improvement_rounded,
  Icons.event_rounded,
  Icons.notes_rounded,
  // Iconsax.timer,
  Icons.menu_book_rounded
];
List descriptionForTypesOfEntries = [
  'This is a task you can check after completed.',
  'This is a habit that repeats at a set interval.',
  'This is an event that you can schedule.',
  'This is a note with rich text editing.',
  // 'This is a timer that helps to you stay focused.',
  'This is a collection of notes as pages.'
];

class _TypesOfObjectsState extends State<TypesOfObjects> {
  final now = DateTime.now();
  String date = '';
  String time = '';
  @override
  void initState() {
// Formate intial date and time to strings
    setState(() {
      date = DateFormat('dd-MM-yyyy').format(now);
      time = DateFormat('h:mm a').format(now);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: typesOfEntries.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return BloomModalListTile(
          onTap: () {
            // Navigate to appropriate page
            if (index == 0) {
              Navigator.pop(context);
              // Add new task process
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                // ),
                builder: (BuildContext context) {
                  return SafeArea(
                    child: AddTaskOrHabitModal(
                      isHabit: false,
                      currentDateTime: DateTime.now(),
                    ),
                  );
                },
                showDragHandle: true,
              );
            } else if (index == 1) {
              Navigator.pop(context);
              // Add new event process
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                enableDrag: true,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: AddTaskOrHabitModal(
                      isHabit: true,
                      currentDateTime: DateTime.now(),
                    ),
                  );
                },
                showDragHandle: true,
              );
            } else if (index == 2) {
              Navigator.pop(context);
              // Add new event process
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                enableDrag: true,
                builder: (BuildContext context) {
                  return AddEventModalSheet(
                    currentDateTime: DateTime.now(),
                  );
                },
                showDragHandle: true,
              );
            } else if (index == 3) {
              // Navigator to the note layout page
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteLayout(
                    hasChildren: false,
                    date: date,
                    time: time,
                    type: 'note',
                    mode: NoteMode.create,
                    dateTime: DateTime.now(),
                    title: '',
                    isEntryLocked: false,
                  ),
                ),
              );
            }
            // else if (index == 3) {
            //   // Add new pomodoro process
            //   showModalBottomSheet(
            //     context: context,
            //     isScrollControlled: true,
            //     useSafeArea: true,
            //     enableDrag: true,
            //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            //     constraints: BoxConstraints(
            //       maxWidth: MediaQuery.of(context).size.width,
            //       maxHeight: MediaQuery.of(context).size.height,
            //     ),
            //     builder: (BuildContext context) {
            //       return AddPomodoro(
            //         currentDateTime: DateTime.now(),
            //       );
            //     },
            //     showDragHandle: true,
            //   );
            // }
            else if (index == 4) {
              // Navigate to the book Layout page
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BookLayout(
                    type: 'book',
                    bookId: 'default',
                    dateTime: now,
                    isFirstTime: true,
                    emoji: '📓',
                    title: 'Book',
                    description:
                        "A Book is a group or collection of similar types of entries with pages and other features.",
                    bookLayoutMethod: BookLayoutMethod.edit,
                    hasChildren: false,
                    isTemplate: false,
                    isFavorite: false,
                    children: const [],
                  ),
                ),
              );
            }
          },
          leadingIcon: Icon(
            iconsForTypesOfEntries[index],
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          title: typesOfEntries[index],
          subTitle: descriptionForTypesOfEntries[index],
        );
      },
    );
  }
}

class BloomModalListTile extends StatefulWidget {
  /// Bloom's custom [ListTile] button for ModalBottomSheets.
  final VoidCallback onTap;
  final String title;
  final String? subTitle;
  final Widget? leadingIcon;
  final TextStyle? titleStyle;
  const BloomModalListTile(
      {super.key,
      required this.onTap,
      required this.title,
      this.subTitle,
      this.leadingIcon,
      this.titleStyle});

  @override
  State<BloomModalListTile> createState() => _BloomModalListTileState();
}

class _BloomModalListTileState extends State<BloomModalListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      dense: true,
      minVerticalPadding: 0,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: widget.leadingIcon ??
            Icon(
              Icons.android,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
      title: Text(
        widget.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.titleStyle ??
            TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      subtitle: widget.subTitle != null && widget.subTitle!.isNotEmpty
          ? Text(
              widget.subTitle ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            )
          : null,
    );
  }
}

class BloomMaterialListTile extends StatefulWidget {
  /// Bloom's custom [ListTile] Material3 Styled button
  final String? label;
  final String? subLabel;
  final TextStyle? labelStyle;
  final TextStyle? subLabelStyle;
  final TextAlign? textAlign;
  final Widget? icon;
  final Function()? onTap;
  final EdgeInsetsGeometry? outerPadding;
  final EdgeInsetsGeometry? innerPadding;
  final Widget? endIcon;
  final Color? color;
  final double? iconLabelSpace;
  final bool? showTag;
  final String? tagLabel;
  final Widget? tagIcon;
  final Color? tagColor;
  final bool? useSpacer;
  final BorderRadius? borderRadius;
  const BloomMaterialListTile({
    super.key,
    this.label,
    this.labelStyle,
    this.textAlign,
    this.icon,
    this.onTap,
    this.outerPadding,
    this.innerPadding,
    this.endIcon,
    this.color,
    this.iconLabelSpace,
    this.showTag,
    this.tagLabel,
    this.tagIcon,
    this.tagColor,
    this.useSpacer,
    this.borderRadius,
    this.subLabel,
    this.subLabelStyle,
  });

  @override
  State<BloomMaterialListTile> createState() => _BloomMaterialListTileState();
}

class _BloomMaterialListTileState extends State<BloomMaterialListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding != null
          ? widget.outerPadding!
          : const EdgeInsets.symmetric(vertical: 1, horizontal: 14),
      child: Material(
        color: widget.color ?? Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          child: Container(
            width: double.maxFinite,
            padding: widget.innerPadding ?? const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.iconLabelSpace != 0)
                  Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color:
                              Theme.of(context).colorScheme.secondaryContainer),
                      child: widget.icon ?? Icon(Icons.android)),
                SizedBox(width: widget.iconLabelSpace ?? 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.label != null && widget.label!.isNotEmpty)
                        Text(
                          widget.label!,
                          maxLines: 1,
                          textAlign: widget.textAlign,
                          style: widget.labelStyle ??
                              TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.subLabel != null &&
                          widget.subLabel!.isNotEmpty)
                        Text(
                          widget.subLabel!,
                          maxLines: 1,
                          textAlign: widget.textAlign,
                          style: widget.subLabelStyle ??
                              TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (widget.showTag == true)
                  const SizedBox(
                    width: 10,
                  ),
                // Show the pro feature tag only if the user is on free plan
                if (widget.showTag == true)
                  Container(
                    decoration: BoxDecoration(
                      color: widget.tagColor ??
                          Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        widget.tagIcon ??
                            Icon(
                              Icons.payment_rounded,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          widget.tagLabel ?? 'Pro feature',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer),
                        )
                      ],
                    ),
                  ),
                if (widget.useSpacer == true) const Spacer(),
                if (widget.endIcon != null) widget.endIcon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Just an icon button for small spaces
class SmallIconButton extends StatefulWidget {
  final Function()? onTap;
  final IconData? icon;
  final String? label;
  final EdgeInsetsGeometry? innerPadding;
  final EdgeInsetsGeometry? outerPadding;
  final Colors? color;
  const SmallIconButton(
      {super.key,
      this.onTap,
      required this.icon,
      this.label,
      this.innerPadding,
      this.outerPadding,
      this.color});

  @override
  State<SmallIconButton> createState() => _SmallIconButtonState();
}

class _SmallIconButtonState extends State<SmallIconButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColorLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: Colors.redAccent,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.label ?? '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void showObjectsModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    enableDrag: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5,
        maxHeight: double.infinity),
    builder: (context) {
      return SafeArea(child: TypesOfObjects());
    },
  );
}

/// Show the Streak [Dialog] for displaying the streak details.
void showStreakDialogBox(BuildContext context, String fieldReference,
    String dialogTitle, bool isTodayCompleted, bool? streakCleared) {
  int streak = 0;
  String selectedQuote = "";
  final List<String> motivationalQuotes = [
    "Believe in yourself and all that you are.",
    "Your limitation—it's only your imagination.",
    "Push yourself, because no one else is going to do it for you.",
    "Dream it. Wish it. Do it.",
    "Great things never come from comfort zones.",
    "Success doesn’t just find you. You have to go out and get it.",
    "Don’t stop when you’re tired. Stop when you’re done.",
    "The harder you work for something, the greater you’ll feel when you achieve it.",
    "Do something today that your future self will thank you for.",
    "It’s going to be hard, but hard does not mean impossible."
  ];
  void getRandomQuote() {
    final random = Random();
    selectedQuote =
        motivationalQuotes[random.nextInt(motivationalQuotes.length)];
  }
  // Future<int> getTasksStreakNumber() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   final firestore = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user?.uid)
  //       .collection('streaks')
  //       .doc('streaks')
  //       .get();
  //   streak = firestore.data()?[fieldReference].length ?? 0;
  //   return firestore.data()?[fieldReference].length ?? 0;
  // }

  showAdaptiveDialog(
    context: context,
    builder: (context) {
      getRandomQuote();
      return AlertDialog.adaptive(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        icon: isTodayCompleted == true
            ? const Text(
                '🔥',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24),
              )
            : streakCleared == false
                ? const Text(
                    '⚠️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  )
                : const Text(
                    '❄️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
        title: isTodayCompleted == true
            ? Text('$streak days')
            : isTodayCompleted == true && streakCleared == false
                ? const Text("Start your streak anew")
                : Text('Streak not extended for today'),
        // titleTextStyle: TextStyle(
        //   fontSize: 24,
        //   fontWeight: FontWeight.w400,
        // ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            isTodayCompleted == false
                ? Text("Complete a goal today to earn a streak point.")
                : Text(
                    "Good job on completing your tasks! Take a break and relax a bit."),
            Text(
              "'${selectedQuote}'",
              textAlign: TextAlign.center,
            )
          ],
        ),
        contentTextStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        actions: [
          TextButton(
              onPressed: () {
                // Close the dialog box
                Navigator.of(context).pop();
                return;
              },
              child: Text('Close'))
        ],
      );
    },
  );
}

class TypesOfEntries extends StatefulWidget {
  /// Modal Bottom sheet to display the types of entries in entries screen
  const TypesOfEntries({super.key});

  @override
  State<TypesOfEntries> createState() => _TypesOfEntriesState();
}

class _TypesOfEntriesState extends State<TypesOfEntries> {
  // Lists of required variables and objects
  List<String> titleOfEntry = ['Note', 'Book'];
  List<IconData> iconOfEntry = [Icons.notes_rounded, Icons.menu_book_rounded];
  List<String> descriptionOfEntry = [
    'This is a note with rich text editing.',
    'This is a collection of notes as pages.'
  ];
  // Format intial date and time to strings
  final now = DateTime.now();
  String date = '';
  String time = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      date = DateFormat('dd-MM-yyyy').format(now);
      time = DateFormat('h:mm a').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: titleOfEntry.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return BloomModalListTile(
            onTap: () {
              if (index == 0) {
                // Navigate to the note layout page
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoteLayout(
                      hasChildren: false,
                      date: date,
                      time: time,
                      type: 'note',
                      mode: NoteMode.create,
                      dateTime: DateTime.now(),
                      title: '',
                      isEntryLocked: false,
                    ),
                  ),
                );
              } else if (index == 1) {
                // Navigate to the book Layout page
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookLayout(
                      type: 'book',
                      bookId: 'default',
                      dateTime: now,
                      isFirstTime: true,
                      emoji: '📓',
                      title: 'Book',
                      description:
                          "A Book is a group or collection of similar types of entries with pages and other features.",
                      bookLayoutMethod: BookLayoutMethod.edit,
                      hasChildren: false,
                      isTemplate: false,
                      isFavorite: false,
                      children: const [],
                    ),
                  ),
                );
              }
            },
            leadingIcon: Icon(
              iconOfEntry[index],
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            title: titleOfEntry[index],
            subTitle: descriptionOfEntry[index],
          );
        });
  }
}

class GoalObjectsModalSheet extends StatefulWidget {
  /// ModalBottomSheet for displaying the goals (tasks, habits, events) [ListTile]'s with Bloom's style.
  const GoalObjectsModalSheet({super.key});

  @override
  State<GoalObjectsModalSheet> createState() => _GoalObjectsModalSheetState();
}

class _GoalObjectsModalSheetState extends State<GoalObjectsModalSheet> {
  // Lists of required variables and objects
  List<String> titleOfEntry = ['Task', 'Habit', 'Event'];
  List<IconData> iconOfEntry = [
    Icons.task_alt_rounded,
    Icons.self_improvement_rounded,
    Icons.event_rounded
  ];
  List<String> descriptionOfEntry = [
    'This is a task you can check after completed.',
    'This is a habit that repeats at a set interval.',
    'This is an event that you can schedule.',
  ];
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: titleOfEntry.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return BloomModalListTile(
            onTap: () {
              if (index == 0) {
                // Navigate to the tasks screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (context) => AddTaskOrHabitModal(
                          currentDateTime: now,
                          isHabit: false,
                        ));
              } else if (index == 1) {
                // Navigate to the habits screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (context) => AddTaskOrHabitModal(
                          currentDateTime: now,
                          isHabit: true,
                        ));
              } else if (index == 2) {
                // Navigate to the events screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    builder: (context) =>
                        AddEventModalSheet(currentDateTime: now));
              }
            },
            leadingIcon: Icon(
              iconOfEntry[index],
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            title: titleOfEntry[index],
            subTitle: descriptionOfEntry[index],
          );
        });
  }
}
