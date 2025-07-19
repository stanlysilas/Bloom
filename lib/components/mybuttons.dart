import 'dart:math';

import 'package:bloom/components/add_event.dart';
// import 'package:bloom/components/add_pomodoro.dart';
import 'package:bloom/components/add_taskorhabit.dart';
import 'package:bloom/models/book_layout.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  'Task', 'Habit', 'Event', 'Note',
  // 'Pomodoro',
  'Book',
  //  'Habit',
// 'Book', 'Page', 'Collection'
];
List iconsForTypesOfEntries = [
  Icons.task_alt_rounded,
  Icons.repeat_rounded,
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
  bool? isFreeSubscription = true;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
// Formate intial date and time to strings
    setState(() {
      date = DateFormat('dd-MM-yyyy').format(now);
      time = DateFormat('h:mm a').format(now);
    });
    checkSubscription();
    super.initState();
  }

  // Check the subscription plan of the user
  void checkSubscription() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final plan = data?['subscriptionPlan'];

        setState(() {
          isFreeSubscription = (plan == null || plan == 'free') ? true : false;
        });
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: typesOfEntries.length,
      itemBuilder: (context, index) {
        return ListTile(
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
                // constraints: BoxConstraints(
                //   maxWidth: MediaQuery.of(context).size.width,
                //   maxHeight: MediaQuery.of(context).size.height,
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
            } else if (index == 1 && isFreeSubscription == false) {
              Navigator.pop(context);
              // Add new event process
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                enableDrag: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // constraints: BoxConstraints(
                //   maxWidth: MediaQuery.of(context).size.width,
                //   maxHeight: MediaQuery.of(context).size.height,
                // ),
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
            } else if (index == 1 && isFreeSubscription == true) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    margin: const EdgeInsets.all(6),
                    behavior: SnackBarBehavior.floating,
                    showCloseIcon: true,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    content: Text(
                        'Upgrade to Pro subscription or Lifetime plan to use Habits')),
              );
            } else if (index == 2) {
              Navigator.pop(context);
              // Add new event process
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                enableDrag: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                // constraints: BoxConstraints(
                //   maxWidth: MediaQuery.of(context).size.width,
                //   maxHeight: MediaQuery.of(context).size.height,
                // ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          dense: true,
          minVerticalPadding: 0,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
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
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          subtitle: Text(
            descriptionForTypesOfEntries[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey),
          ),
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
  final bool? useSpacer;
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
    this.useSpacer,
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
          width: double.maxFinite,
          padding: widget.innerPadding ??
              const EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 2),
          decoration: widget.decoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon ?? const SizedBox(),
              SizedBox(width: widget.iconLabelSpace ?? 0),
              if (widget.label != '' || widget.label != null)
                Text(
                  widget.label!,
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
                        Theme.of(context).primaryColor.withAlpha(100),
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
              if (widget.useSpacer == true) const Spacer(),
              if (widget.endIcon != null) widget.endIcon!,
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

void showObjectsModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    enableDrag: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    builder: (context) {
      return SafeArea(child: TypesOfObjects());
    },
  );
}

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
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        content: isTodayCompleted == false
            ? Text(
                "Complete a goal today to earn a streak point. \t $selectedQuote")
            : Text(
                "Good job on completing your tasks! Take a break and relax a bit. $selectedQuote"),
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

// Modal Bottom sheet to display the types of entries in entries screen
class TypesOfEntries extends StatefulWidget {
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
        itemBuilder: (context, index) {
          return ListTile(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            dense: true,
            minVerticalPadding: 0,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            subtitle: Text(
              descriptionOfEntry[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          );
        });
  }
}

// Modal sheet class for displaying the goals (tasks, habits, events) adding sheet
class GoalObjectsModalSheet extends StatefulWidget {
  const GoalObjectsModalSheet({super.key});

  @override
  State<GoalObjectsModalSheet> createState() => _GoalObjectsModalSheetState();
}

class _GoalObjectsModalSheetState extends State<GoalObjectsModalSheet> {
  // Lists of required variables and objects
  final userId = FirebaseAuth.instance.currentUser?.uid;
  List<String> titleOfEntry = ['Task', 'Habit', 'Event'];
  List<IconData> iconOfEntry = [
    Icons.task_alt_rounded,
    Icons.repeat_rounded,
    Icons.event_rounded
  ];
  List<String> descriptionOfEntry = [
    'This is a task you can check after completed.',
    'This is a habit that repeats at a set interval.',
    'This is an event that you can schedule.',
  ];
  final now = DateTime.now();
  bool? isFreeSubscription = true;

  @override
  void initState() {
    super.initState();
    checkSubscription();
  }

  // Check the subscription plan of the user
  void checkSubscription() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final plan = data?['subscriptionPlan'];

        setState(() {
          isFreeSubscription = (plan == null || plan == 'free') ? true : false;
        });
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: titleOfEntry.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              if (index == 0) {
                // Navigate to the tasks screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    builder: (context) => AddTaskOrHabitModal(
                          currentDateTime: now,
                          isHabit: false,
                        ));
              } else if (index == 1 && isFreeSubscription == false) {
                // Navigate to the habits screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    builder: (context) => AddTaskOrHabitModal(
                          currentDateTime: now,
                          isHabit: true,
                        ));
              } else if (index == 1 && isFreeSubscription == true) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      margin: const EdgeInsets.all(6),
                      behavior: SnackBarBehavior.floating,
                      showCloseIcon: true,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      content: Text(
                          'Upgrade to Pro subscription or Lifetime plan to use Habits')),
                );
              } else if (index == 2) {
                // Navigate to the events screen
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    builder: (context) =>
                        AddEventModalSheet(currentDateTime: now));
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            dense: true,
            minVerticalPadding: 0,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            subtitle: Text(
              descriptionOfEntry[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey),
            ),
          );
        });
  }
}
