import 'package:bloom/components/habit_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Habitstabview extends StatefulWidget {
  final bool toggleSearch;
  final bool toggleDayView;
  final DateTime focusedDay;
  const Habitstabview(
      {super.key,
      required this.toggleSearch,
      required this.toggleDayView,
      required this.focusedDay});

  @override
  State<Habitstabview> createState() => _HabitstabviewState();
}

class _HabitstabviewState extends State<Habitstabview> {
  final user = FirebaseAuth.instance.currentUser;
  // Method to fetch habits
  Stream<QuerySnapshot> fetchHabits(DateTime day) {
    var dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    var dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('habits');

    // Apply date filter if toggleDayView is enabled
    if (widget.toggleDayView) {
      query = query
          .where('habitDateTime', isGreaterThanOrEqualTo: dayStart)
          .where('habitDateTime', isLessThanOrEqualTo: dayEnd);
    }

    // Apply completion filter (if not empty or null)
    // if (completedSortValue == 'Completed') {
    //   query = query.where('isCompleted', isEqualTo: true);
    // } else if (completedSortValue == 'Incomplete') {
    //   query = query.where('isCompleted', isEqualTo: false);
    // }

    // // Sorting logic based on priority and task date
    // bool isPriorityHighToLow = priorityLevel == 'High to Low';
    // bool isRecentTasks = sortValue == 'Recent tasks';

    // query = query
    //     .orderBy('priorityLevel',
    //         descending: !isPriorityHighToLow) // High to Low or Low to High
    //     .orderBy('taskDateTime', descending: isRecentTasks); // Recent or Oldest

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            if (!widget.toggleSearch)
              StreamBuilder<QuerySnapshot>(
                  stream: fetchHabits(widget.focusedDay),
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
                      return const SizedBox(
                        child: Padding(
                          padding: EdgeInsets.only(left: 14.0, right: 14.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage(
                                      'assets/images/allCompletedBackground.png'),
                                ),
                                Text(
                                  'No habits...',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
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
                          ),
                        ),
                      )
                          .animate()
                          .fade(delay: const Duration(milliseconds: 100));
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child:
                            Text('There was an error trying to fetch habits.'),
                      );
                    }
                    List tasksList = snapshot.data!.docs;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
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
                          DateTime habitDateTime = timestamp.toDate();
                          List habitGroups = data['habitGroups'];
                          Timestamp timeStamp = data['addedOn'];
                          DateTime addedOn = timeStamp.toDate();
                          return Column(
                            children: [
                              HabitTile(
                                innerPadding: const EdgeInsets.only(
                                    right: 14, top: 4, bottom: 4),
                                habitId: habitId,
                                habitName: habitName,
                                habitNotes: habitNotes,
                                habitDateTime: habitDateTime,
                                habitGroups: habitGroups,
                                daysOfWeek: daysOfWeek,
                                completedDaysOfWeek: completedDaysOfWeek,
                                addedOn: addedOn,
                                habitUniqueId: habitUniqueId,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: const Divider().animate().fade(
                                    delay: const Duration(milliseconds: 250)),
                              )
                            ],
                          );
                        },
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }
}
