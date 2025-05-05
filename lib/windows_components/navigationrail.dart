import 'dart:io';

import 'package:bloom/components/mybuttons.dart';
// import 'package:bloom/models/note_layout.dart';
import 'package:bloom/screens/dashboard_screen.dart';
import 'package:bloom/screens/display_pomodoro_screen.dart';
import 'package:bloom/screens/entries_screen.dart';
import 'package:bloom/screens/eventsandschedules_screen.dart';
import 'package:bloom/screens/profile_screen.dart';
import 'package:bloom/screens/tasksandhabits_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skeletonizer/skeletonizer.dart';

class Navigationrail extends StatefulWidget {
  const Navigationrail({super.key});

  @override
  State<Navigationrail> createState() => _NavigationrailState();
}

class _NavigationrailState extends State<Navigationrail> {
  final user = FirebaseAuth.instance.currentUser;
  int currentPageIndex = 0;
  bool? showSideBar;
  final screens = [
    DashboardScreen(isAndroid: Platform.isAndroid),
    const TaskScreen(),
    const SchedulesScreen(),
    const EntriesScreen(),
    const DisplayPomodoroScreen(),
  ];
  String? profilePicture;
  String? email;
  String? userName = '..';
  String? font;
  bool? isImageNetwork;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  // Fetch accountData
  void fetchAccountData() async {
    // Replace 'users' with your actual collection name
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      profilePicture = data?['profilePicture'];
      email = data?['email'];
      userName = data?['userName'];
      isImageNetwork = data?['isImageNetwork'];
    } else {}
  }

  // Set sidebar
  void getSideBarStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final test = prefs.getBool('showSideBar');
    setState(() {
      showSideBar = test!;
    });
  }

  Stream<QuerySnapshot> fetchEntriesForDay() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('entries')
        .orderBy('addedOn', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final navigationrailProvider = Provider.of<NavigationrailProvider>(context);
    return Scaffold(
      body: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 10),
              curve: Curves.easeInBack,
              tween: Tween<double>(
                begin: navigationrailProvider.showSideBar ? 0.0 : 1.0,
                end: navigationrailProvider.showSideBar ? 1.0 : 0.0,
              ),
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: SizedBox(
                    width: navigationrailProvider.showSideBar ? 255.0 : 72.0,
                    height: MediaQuery.of(context).size.height,
                    child: NavigationRail(
                      indicatorColor: Theme.of(context).primaryColor,
                      extended:
                          navigationrailProvider.showSideBar ? true : false,
                      backgroundColor: Theme.of(context).primaryColorLight,
                      leading: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (navigationrailProvider.showSideBar)
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text(
                                'Logged in as',
                                style: TextStyle(),
                              ),
                            ),
                          SizedBox(
                            width: value == 0.0 ? value + 72.0 : value + 255.0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorDark,
                                    borderRadius: BorderRadius.circular(8)),
                                child: ExtraOptionsButton(
                                  innerPadding: const EdgeInsets.all(8),
                                  icon: isImageNetwork == true
                                      ? Image.network(profilePicture!)
                                      : Image.asset(
                                          profilePicture ??
                                              'assets/profile_pictures/Profile_Picture_Male.png',
                                          scale:
                                              navigationrailProvider.showSideBar
                                                  ? 38
                                                  : 28,
                                        ),
                                  iconLabelSpace:
                                      navigationrailProvider.showSideBar
                                          ? 8
                                          : 2,
                                  label: navigationrailProvider.showSideBar
                                      ? userName
                                      : null,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                        isImageNetwork: isImageNetwork ?? false,
                                        profilePicture: profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male.png',
                                        userName: userName ?? '...',
                                        uid: user!.uid,
                                        email: email ?? 'email',
                                        mode: ProfileMode.display,
                                      ),
                                    ),
                                  ),
                                  endIcon: navigationrailProvider.showSideBar
                                      ? const Icon(
                                          Icons
                                              .keyboard_double_arrow_right_rounded,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (navigationrailProvider.showSideBar)
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text(
                                'Navigate to',
                                style: TextStyle(),
                              ),
                            ),
                        ],
                      ),
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Iconsax.home,
                              color: currentPageIndex == 0
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : null),
                          label: const Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Iconsax.task_square4,
                              color: currentPageIndex == 1
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : null),
                          label: const Text('Tasks'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Iconsax.calendar_1,
                              color: currentPageIndex == 2
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : null),
                          label: const Text('Schedules'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Iconsax.book_1,
                              color: currentPageIndex == 3
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : null),
                          label: const Text('Entries'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Iconsax.timer,
                              color: currentPageIndex == 4
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : null),
                          label: const Text('Pomodoro'),
                        ),
                      ],
                      // trailing: currentPageIndex == 3
                      //     ? const SizedBox()
                      //     : SizedBox(
                      //         child: Column(
                      //           crossAxisAlignment:
                      //               CrossAxisAlignment.start,
                      //           children: [
                      //             const SizedBox(
                      //               height: 15,
                      //             ),
                      //             const Padding(
                      //               padding: EdgeInsets.only(
                      //                   left: 8.0, right: 8.0, bottom: 8.0),
                      //               child: Text(
                      //                 'Recent entries',
                      //                 style: TextStyle(),
                      //               ),
                      //             ),
                      //             StreamBuilder<QuerySnapshot>(
                      //               stream: fetchEntriesForDay(),
                      //               builder: (context, snapshot) {
                      //                 if (snapshot.connectionState ==
                      //                     ConnectionState.waiting) {
                      //                   return const Skeletonizer(
                      //                     enabled: true,
                      //                     child: ListTile(
                      //                       leading: Icon(Icons.abc),
                      //                       dense: true,
                      //                       title: Text(
                      //                         'So this is the text of the title of the object here...',
                      //                         style: TextStyle(
                      //                           fontWeight:
                      //                               FontWeight.bold,
                      //                           fontSize: 18,
                      //                         ),
                      //                         maxLines: 1,
                      //                       ),
                      //                     ),
                      //                   ).animate().fade(
                      //                       delay: const Duration(
                      //                           milliseconds: 50));
                      //                 }
                      //                 if (snapshot.hasData &&
                      //                     snapshot.data!.docs.isEmpty) {
                      //                   return SizedBox(
                      //                     height: MediaQuery.of(context)
                      //                         .size
                      //                         .height,
                      //                     child: const Text(
                      //                       'No entries made',
                      //                       style: TextStyle(
                      //                           fontWeight:
                      //                               FontWeight.w600),
                      //                       textAlign: TextAlign.center,
                      //                     ),
                      //                   ).animate().fadeIn(
                      //                         delay: const Duration(
                      //                             milliseconds: 100),
                      //                       );
                      //                 }
                      //                 if (snapshot.hasError) {
                      //                   return const Center(
                      //                     child: Text(
                      //                         'Encountered an error while retrieving entries.'),
                      //                   ).animate().fadeIn(
                      //                         duration: const Duration(
                      //                             milliseconds: 500),
                      //                       );
                      //                 }
                      //                 final entries =
                      //                     snapshot.data!.docs;
                      //                 return ListView.builder(
                      //                     itemCount: entries.length,
                      //                     shrinkWrap: true,
                      //                     physics:
                      //                         const NeverScrollableScrollPhysics(),
                      //                     itemBuilder:
                      //                         (context, index) {
                      //                       final entry =
                      //                           entries[index];
                      //                       final entryDescription =
                      //                           entry['mainEntryDescription'] ??
                      //                               '{}';
                      //                       final entryTitle = entry[
                      //                               'mainEntryTitle'] ??
                      //                           '';
                      //                       final entryBackgroundImageUrl =
                      //                           entry['backgroundImageUrl'] ??
                      //                               '';
                      //                       final entryId =
                      //                           entry['mainEntryId'] ??
                      //                               '';
                      //                       final entryType = entry[
                      //                               'mainEntryType'] ??
                      //                           '';
                      //                       final entryEmoji = entry[
                      //                               'mainEntryEmoji'] ??
                      //                           '';
                      //                       final entryAttachments =
                      //                           entry['attachments'] ??
                      //                               [];
                      //                       final entryChildren =
                      //                           entry['children'];
                      //                       final entryHasChildren =
                      //                           entry['hasChildren'];
                      //                       final Timestamp timestamp =
                      //                           entry['addedOn'];
                      //                       final Timestamp datetime =
                      //                           entry['dateTime'];
                      //                       final DateTime entryDate =
                      //                           timestamp.toDate();
                      //                       final DateTime dateTime =
                      //                           datetime.toDate();
                      //                       // final DateTime addedOn = entryDate;
                      //                       final entryIsFavorite =
                      //                           entry['isFavorite'];
                      //                       final date =
                      //                           DateFormat('dd-MM-yyyy')
                      //                               .format(entryDate);
                      //                       final entryTime =
                      //                           entry['dateTime']
                      //                                   ?.toDate() ??
                      //                               '';
                      //                       final time =
                      //                           DateFormat('h:mm a')
                      //                               .format(entryTime);
                      //                       final isSynced =
                      //                           entry['synced'];
                      //                       final isEntryLocked =
                      //                           entry['isEntryLocked'];
                      //                       return Column(
                      //                         children: [
                      //                           ListTile(
                      //                             dense: true,
                      //                             leading:
                      //                                 Text(entryEmoji),
                      //                             title: Text(
                      //                               entryTitle,
                      //                               style: TextStyle(
                      //                                   color: Theme.of(
                      //                                           context)
                      //                                       .textTheme
                      //                                       .bodyMedium
                      //                                       ?.color),
                      //                             ),
                      //                             onTap: () => Navigator
                      //                                     .of(context)
                      //                                 .push(
                      //                                     MaterialPageRoute(
                      //                               builder:
                      //                                   (context) =>
                      //                                       NoteLayout(
                      //                                 description:
                      //                                     entryDescription,
                      //                                 title: entryTitle,
                      //                                 emoji: entryEmoji,
                      //                                 attachments:
                      //                                     entryAttachments,
                      //                                 noteId: entryId,
                      //                                 childNotes:
                      //                                     entryChildren,
                      //                                 backgroundImageUrl:
                      //                                     entryBackgroundImageUrl,
                      //                                 isFavorite:
                      //                                     entryIsFavorite,
                      //                                 isSynced:
                      //                                     isSynced,
                      //                                 hasChildren:
                      //                                     entryHasChildren,
                      //                                 date: date,
                      //                                 time: time,
                      //                                 type: entryType,
                      //                                 mode: NoteMode
                      //                                     .display,
                      //                                 dateTime:
                      //                                     dateTime,
                      //                                 isEntryLocked:
                      //                                     isEntryLocked,
                      //                               ),
                      //                             )),
                      //                           ),
                      //                           Padding(
                      //                             padding:
                      //                                 const EdgeInsets
                      //                                     .symmetric(
                      //                                     horizontal:
                      //                                         14.0),
                      //                             child: const Divider()
                      //                                 .animate()
                      //                                 .fade(
                      //                                     delay: const Duration(
                      //                                         milliseconds:
                      //                                             250)),
                      //                           )
                      //                         ],
                      //                       );
                      //                     });
                      //               },
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      selectedIndex: currentPageIndex,
                      onDestinationSelected: (currentPageIndex) => setState(
                          () => this.currentPageIndex = currentPageIndex),
                    ),
                  ),
                );
              }),
          navigationrailProvider.showSideBar
              ?
              // When the sideBar is enabled or largened
              Expanded(
                  child: Padding(
                  padding: Platform.isWindows
                      ? const EdgeInsets.symmetric(horizontal: 120.0)
                      : const EdgeInsets.all(0.0),
                  child: screens[currentPageIndex],
                )).animate().fade()
              :
              // When the sideBar is disabled or shortened
              Expanded(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 150.0),
                        child: screens[currentPageIndex],
                      )).animate().fade(),
                )
        ],
      ),
    );
  }
}

class NavigationrailProvider extends ChangeNotifier {
  bool _showSideBar = true;
  bool get showSideBar => _showSideBar;

  void toggleSideBar() {
    _showSideBar = !_showSideBar;
    notifyListeners();
  }

  void setSideBarStatus(bool value) {
    if (_showSideBar != value) {
      _showSideBar = value;
      notifyListeners();
    }
  }
}
