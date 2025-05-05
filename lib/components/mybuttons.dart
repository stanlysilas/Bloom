import 'dart:math';

import 'package:bloom/components/add_event.dart';
import 'package:bloom/components/add_pomodoro.dart';
import 'package:bloom/components/add_taskorhabit.dart';
import 'package:bloom/models/book_layout.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:bloom/required_data/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// Multiple entries button
class TypesOfObjects extends StatefulWidget {
  const TypesOfObjects({
    super.key,
  });

  @override
  State<TypesOfObjects> createState() => _TypesOfObjectsState();
}

List typesOfEntries = [
  'Task', 'Event', 'Note',
  'Pomodoro',
  'Book',
  //  'Habit',
// 'Book', 'Page', 'Collection'
];
List iconsForTypesOfEntries = [
  Iconsax.task_square,
  Iconsax.calendar_1,
  Iconsax.book,
  Iconsax.timer,
  Iconsax.book_1
];
List descriptionForTypesOfEntries = [
  'This is a task you can check after completed.',
  'This is an event that you can schedule.',
  'This is a note with rich text editing.',
  'This is a timer that helps to you stay focused.',
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
      itemBuilder: (context, index) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                // Navigate to appropriate page
                if (index == 0) {
                  Navigator.pop(context);
                  // Add new task process
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    builder: (BuildContext context) {
                      return Scaffold(
                        body: AddTaskOrHabitModal(
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
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    builder: (BuildContext context) {
                      return AddEventModalSheet(
                        currentDateTime: DateTime.now(),
                      );
                    },
                    showDragHandle: true,
                  );
                } else if (index == 2) {
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
                } else if (index == 3) {
                  // Add new pomodoro process
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    enableDrag: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width,
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    builder: (BuildContext context) {
                      return AddPomodoro(
                        currentDateTime: DateTime.now(),
                      );
                    },
                    showDragHandle: true,
                  );
                } else if (index == 4) {
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                dense: true,
                minVerticalPadding: 0,
                leading: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Icon(
                    iconsForTypesOfEntries[index],
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                title: Text(
                  typesOfEntries[index],
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                subtitle: Text(
                  descriptionForTypesOfEntries[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 0),
              child: Divider(),
            ),
          ],
        );
      },
    );
  }
}

class ExtraOptionsButton extends StatefulWidget {
  final String? label;
  final TextStyle? labelStyle;
  final TextAlign? textAlign;
  final Widget? icon;
  final Function()? onTap;
  final EdgeInsetsGeometry? outerPadding;
  final EdgeInsetsGeometry? innerPadding;
  final Widget? endIcon;
  final BoxDecoration? decoration;
  final double? iconLabelSpace;
  final bool? showTag;
  final String? tagLabel;
  final Widget? tagIcon;
  final Color? tagColor;
  const ExtraOptionsButton({
    super.key,
    this.label,
    this.labelStyle,
    this.textAlign,
    this.icon,
    this.onTap,
    this.outerPadding,
    this.innerPadding,
    this.endIcon,
    this.decoration,
    this.iconLabelSpace,
    this.showTag,
    this.tagLabel,
    this.tagIcon,
    this.tagColor,
  });

  @override
  State<ExtraOptionsButton> createState() => _ExtraOptionsButtonState();
}

class _ExtraOptionsButtonState extends State<ExtraOptionsButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding != null
          ? widget.outerPadding!
          : const EdgeInsets.only(),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: widget.innerPadding ??
              const EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
          decoration: widget.decoration,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              widget.icon ?? const SizedBox(),
              SizedBox(width: widget.iconLabelSpace ?? 0),
              Text(
                widget.label ?? '',
                maxLines: 1,
                textAlign: widget.textAlign,
                style: widget.labelStyle,
                overflow: TextOverflow.ellipsis,
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
                        secondaryColorLightMode.withAlpha(60),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      widget.tagIcon ??
                          const Icon(
                            Icons.payment_rounded,
                            size: 14,
                          ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        widget.tagLabel ?? 'Pro feature',
                        style: const TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
              const Spacer(),
              widget.endIcon ?? const SizedBox(),
            ],
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

void showMyCustomModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    enableDrag: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return const Column(
        children: [
          Text(
            'Basic objects',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          // Display all the basic objects
          Expanded(
            child: TypesOfObjects(),
          ),
          // Display a button to more templates
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const Text(
          //       'More object ',
          //     ),
          //     InkWell(
          //       onTap: () => Navigator.of(context).push(MaterialPageRoute(
          //           builder: (context) => const CustomTemplatesScreen())),
          //       child: const Row(
          //         children: [
          //           Text(
          //             'templates',
          //             style: TextStyle(
          //                 decoration: TextDecoration.underline,
          //                 fontWeight: FontWeight.w700),
          //           ),
          //           Icon(
          //             Icons.open_in_new_rounded,
          //             size: 14,
          //           )
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 8)
        ],
      );
    },
  );
}

void showStreakDialogBox(BuildContext context, String fieldReference,
    String dialogTitle, bool isTodayCompleted, bool? streakCleared) {
  Future<int> getTasksStreakNumber() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('streaks')
        .doc('streaks')
        .get();
    return firestore.data()?[fieldReference].length ?? 0;
  }

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(14),
          child: FutureBuilder<int>(
            future: getTasksStreakNumber(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColorLight,
                ));
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching streak.'));
              }

              int streak = snapshot.data ?? 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isTodayCompleted == true
                        ? const Text(
                            '🔥',
                            style: TextStyle(fontSize: 28),
                          )
                        : streakCleared == false
                            ? const Text(
                                '⚠️',
                                style: TextStyle(fontSize: 28),
                              )
                            : const Text(
                                '❄️',
                                style: TextStyle(fontSize: 28),
                              ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  isTodayCompleted == true
                      ? Text(
                          '$streak days',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : isTodayCompleted == true && streakCleared == false
                          ? const Text(
                              "Start your streak anew",
                              style: TextStyle(fontSize: 16),
                            )
                          : const Text(
                              'Task streak not extended for today',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                  const SizedBox(
                    height: 18,
                  ),
                  isTodayCompleted == false
                      ? const Text(
                          'Complete a task today to earn a streak point',
                          textAlign: TextAlign.center,
                        )
                      : const Text(
                          'Good job on completing your tasks! Take a break and relax a bit.',
                          textAlign: TextAlign.center,
                        ),
                  const Spacer(),
                  const MotivationalQuoteWidget(),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

// Motivational quotes widget

class MotivationalQuoteWidget extends StatefulWidget {
  const MotivationalQuoteWidget({super.key});

  @override
  State<MotivationalQuoteWidget> createState() =>
      _MotivationalQuoteWidgetState();
}

class _MotivationalQuoteWidgetState extends State<MotivationalQuoteWidget> {
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

  String selectedQuote = "";

  @override
  void initState() {
    super.initState();
    getRandomQuote(); // Select a random quote when the widget initializes
  }

  void getRandomQuote() {
    final random = Random();
    setState(() {
      selectedQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      selectedQuote,
      textAlign: TextAlign.center,
    );
  }
}

// Modal Bottom sheet to display the types of entries in entries screen
class TypesOfEntries extends StatefulWidget {
  const TypesOfEntries({super.key});

  @override
  State<TypesOfEntries> createState() => _TypesOfEntriesState();
}

class _TypesOfEntriesState extends State<TypesOfEntries> {
  // Lists of required variables and objects
  List<String> titleOfEntry = ['Note', 'Book'];
  List<IconData> iconOfEntry = [Iconsax.book, Iconsax.book_1];
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
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  dense: true,
                  minVerticalPadding: 0,
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColorLight,
                    ),
                    child: Icon(
                      iconOfEntry[index],
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  title: Text(
                    titleOfEntry[index],
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  subtitle: Text(
                    descriptionOfEntry[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 0),
                child: Divider(),
              ),
            ],
          );
        });
  }
}
