import 'package:bloom/components/habit_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Habitstabview extends StatefulWidget {
  const Habitstabview({super.key});

  @override
  State<Habitstabview> createState() => _HabitstabviewState();
}

class _HabitstabviewState extends State<Habitstabview> {
  // Required variables
  String sortValue = 'recent';
  final user = FirebaseAuth.instance.currentUser;
  final List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  // Method to fetch habits
  Stream<QuerySnapshot> fetchHabits() {
    final day = DateTime.now();
    var dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    var dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits');

    // Apply completion filter (if not empty or null)
    if (sortValue == 'all') {
      query = query;
    }
    // else if (sortValue == 'recent') {
    //   query = query
    //       .orderBy('habitDateTime', descending: true);
    // }
    else if (sortValue == 'oldest') {
      query = query.orderBy('habitDateTime', descending: false);
    } else if (sortValue == 'today') {
      query = query
          .where('habitDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('habitDateTime', isLessThanOrEqualTo: dayEnd);
    }

    return query.orderBy('habitDateTime', descending: true).snapshots();
  }

  void stateUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 8,
                children: [
                  // Default sorting button
                  RawChip(
                    backgroundColor: sortValue != 'recent'
                        ? Theme.of(context).colorScheme.surfaceVariant
                        : Theme.of(context).colorScheme.secondaryContainer,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    onPressed: () {
                      setState(() {
                        sortValue = 'recent';
                      });
                    },
                    avatar: Icon(sortValue != 'recent'
                        ? Icons.filter_list_off_rounded
                        : Icons.check_rounded),
                    label: Text('Default'),
                  ),
                  // Custom filters button
                  RawChip(
                    backgroundColor: sortValue != 'recent'
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                    side: BorderSide.none,
                    labelStyle: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    iconTheme: IconThemeData(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    onPressed: () {
                      // Functionality to show the filter and other options as a modal bottom sheet
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              title: const Text('Filters'),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 8),
                              content: StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return SingleChildScrollView(
                                  child: SizedBox(
                                    height: 260,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // All habits button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'all',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'All',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle:
                                              Text('Show all your habits'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'all';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Today button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'today',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Today',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Show only the habits for today'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'today';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Recent button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'recent',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Recent',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the habits from recent to oldest'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'recent';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                        // Oldest button
                                        ListTile(
                                          dense: true,
                                          minVerticalPadding: 0,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          leading: Radio.adaptive(
                                              value: 'oldest',
                                              groupValue: sortValue,
                                              onChanged: (String? sortvalue) {
                                                setState(() {
                                                  sortValue = sortvalue!;
                                                });
                                                stateUpdate();
                                              }),
                                          horizontalTitleGap: 0,
                                          title: Text(
                                            'Oldest',
                                            textAlign: TextAlign.start,
                                          ),
                                          subtitle: Text(
                                              'Sort the habits from oldest to recent'),
                                          titleTextStyle: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color),
                                          subtitleTextStyle:
                                              TextStyle(color: Colors.grey),
                                          onTap: () {
                                            setState(() {
                                              sortValue = 'oldest';
                                            });
                                            stateUpdate();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              actions: [
                                // Cancel button
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    return;
                                  },
                                  child: Text('Close'),
                                ),
                              ],
                            );
                          });
                    },
                    avatar: Icon(sortValue != 'recent'
                        ? Icons.check_rounded
                        : Icons.filter_list_rounded),
                    label: Text('Filter'),
                  ),
                  Spacer(),
                  // Topbar for displaying the day of the week name parallel to the buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ...List.generate(daysOfWeek.length, (index) {
                        return Padding(
                            padding:
                                EdgeInsetsGeometry.symmetric(horizontal: 5.5),
                            child: Text(daysOfWeek[index]));
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder<QuerySnapshot>(
                stream: fetchHabits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                      enabled: true,
                      containersColor: Theme.of(context).primaryColorLight,
                      child: const ListTile(
                        leading: Icon(Icons.abc),
                        title: Text(
                          'So this is the text of the title of the object here...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          'So this is the text of the subtitle of the object here...',
                          maxLines: 1,
                        ),
                        trailing: Text('End'),
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 50));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              height: 250,
                              width: 250,
                              image: AssetImage(
                                  'assets/images/habitsEmptyBackground.png'),
                            ),
                            Text(
                              'You have no habits',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Click on the + icon to create and nurture a new good habit',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 14,
                            )
                          ],
                        ),
                      )
                          .animate()
                          .fade(delay: const Duration(milliseconds: 100)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('There was an error trying to fetch habits.'),
                    );
                  }
                  List tasksList = snapshot.data!.docs;
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: tasksList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = tasksList[index];
                      String habitId = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String habitName = data['habitName'];
                      String habitNotes = data['habitNotes'];
                      int habitUniqueId = data['habitUniqueId'] ?? 0;
                      Timestamp timestamp = data['habitDateTime'];
                      List daysOfWeek = data['daysOfWeek'] ?? [];
                      List completedDaysOfWeek =
                          data['completedDaysOfWeek'] ?? [];
                      List completedDates = data['completedDates'] ?? [];
                      DateTime habitDateTime = timestamp.toDate();
                      List habitGroups = data['habitGroups'];
                      Timestamp timeStamp = data['addedOn'];
                      DateTime addedOn = timeStamp.toDate();
                      return HabitTile(
                        innerPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        habitId: habitId,
                        habitName: habitName,
                        habitNotes: habitNotes,
                        habitDateTime: habitDateTime,
                        habitGroups: habitGroups,
                        daysOfWeek: daysOfWeek,
                        completedDaysOfWeek: completedDaysOfWeek,
                        addedOn: addedOn,
                        habitUniqueId: habitUniqueId,
                        completedDates: completedDates,
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
