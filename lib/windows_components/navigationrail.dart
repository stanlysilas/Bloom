import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:bloom/screens/custom_templates_screen.dart';
import 'package:bloom/screens/dashboard_screen.dart';
import 'package:bloom/screens/entries_screen.dart';
import 'package:bloom/screens/moreoptions_screen.dart';
import 'package:bloom/screens/profile_screen.dart';
import 'package:bloom/screens/goals_screen.dart';
import 'package:bloom/screens/upgrade_subscription_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Navigationrail extends StatefulWidget {
  const Navigationrail({super.key});

  @override
  State<Navigationrail> createState() => _NavigationrailState();
}

class _NavigationrailState extends State<Navigationrail> {
  final user = FirebaseAuth.instance.currentUser;
  int currentPageIndex = 0;
  bool? _extended = false;
  final screens = [
    DashboardScreen(
        isAndroid:
            defaultTargetPlatform == TargetPlatform.android ? true : false),
    const GoalsScreen(),
    const EntriesScreen(),
    // const DisplayPomodoroScreen(),
    const MoreOptionsScreen(),
  ];
  String? profilePicture;
  String? email;
  String? userName = '..';
  String? subscriptionPlan;
  String? font;
  bool? isImageNetwork;

  @override
  void initState() {
    super.initState();
    fetchAccountData();
    // _extended = true;
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
      subscriptionPlan = data?['subscriptionPlan'] ?? 'free';
    } else {}
  }

  // Set sidebar
  // void getSideBarStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final test = prefs.getBool('showSideBar');
  //   setState(() {
  //     _extended = test!;
  //   });
  // }

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
    return Scaffold(
      extendBody: true,
      body: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NavigationRail(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            scrollable: true,
            labelType: _extended!
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            extended: _extended!,
            minWidth: 72,
            minExtendedWidth: 255,
            leading: MediaQuery.of(context).size.width > mobileWidth
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Display the logo/icon of the app here
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 6,
                          children: [
                            if (_extended! &&
                                defaultTargetPlatform != TargetPlatform.android)
                              Image.asset(
                                'assets/icons/default_app_icon_png.png',
                                scale: 20,
                              ),
                            if (_extended! &&
                                defaultTargetPlatform != TargetPlatform.android)
                              Text(
                                'Bloom',
                                style: TextStyle(
                                    fontFamily: 'ClashGrotesk',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500),
                              ),
                            IconButton(
                                tooltip:
                                    _extended! ? 'Close menu' : 'Open menu',
                                icon: Icon(_extended!
                                    ? Icons.close_fullscreen
                                    : Icons.menu_open),
                                onPressed: () {
                                  setState(() {
                                    _extended = !_extended!;
                                  });
                                }),
                          ],
                        ),
                      ),
                      if (_extended! &&
                          defaultTargetPlatform != TargetPlatform.android)
                        Padding(
                          padding: EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logged in as',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                          isImageNetwork: isImageNetwork,
                                          profilePicture: profilePicture,
                                          userName:
                                              userName == '' || userName == null
                                                  ? user!.email!.substring(0, 8)
                                                  : userName,
                                          uid: user!.uid,
                                          email: email,
                                          mode: ProfileMode.display)));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  width: _extended! ? 255 : 72,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      (profilePicture != null ||
                                              profilePicture != '')
                                          ? isImageNetwork == true
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadiusGeometry
                                                          .circular(10),
                                                  child: Image.network(
                                                    profilePicture!,
                                                    scale: 3,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Center(
                                                        child: Text(
                                                          '😿',
                                                          style: TextStyle(
                                                              fontSize: 22),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadiusGeometry
                                                          .circular(16),
                                                  child: Image.asset(
                                                    profilePicture!,
                                                    scale: 32,
                                                  ),
                                                )
                                          : Icon(Icons.account_circle_rounded),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      userName == null || userName == ''
                                          ? Text(user!.email!.substring(0, 8))
                                          : Text(userName!),
                                      Spacer(),
                                      Icon(Icons.more_horiz_rounded)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_extended!)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text(
                            'Navigate to',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  )
                : null,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_rounded),
                label: const Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.task_rounded),
                label: const Text('Goals'),
              ),
              // NavigationRailDestination(
              //   icon: Icon(Icons.calendar_month_rounded),
              //   label: const Text('Schedules'),
              // ),
              NavigationRailDestination(
                icon: Icon(Icons.book_rounded),
                label: const Text('Entries'),
              ),
              // NavigationRailDestination(
              //   icon: Icon(Iconsax.timer,
              //       color: currentPageIndex == 4
              //           ? Theme.of(context).scaffoldBackgroundColor
              //           : null),
              //   label: const Text('Pomodoro'),
              // ),
              NavigationRailDestination(
                icon: Icon(Icons.more_horiz_rounded),
                label: const Text('More'),
              ),
            ],
            trailingAtBottom: true,
            trailing: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton.extended(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  isExtended: _extended!,
                  tooltip: 'Create new object',
                  onPressed: () {
                    if (currentPageIndex == 0) {
                      // All objects adding sheet
                      showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          useSafeArea: true,
                          builder: (context) => TypesOfObjects());
                    } else if (currentPageIndex == 1) {
                      // Add new goal process
                      showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          useSafeArea: true,
                          builder: (context) => GoalObjectsModalSheet());
                    } else if (currentPageIndex == 2) {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        enableDrag: true,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              children: [
                                // Display all the basic objects
                                const Expanded(
                                  child: TypesOfEntries(),
                                ),
                                // Display a button to more templates
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'More entry ',
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (subscriptionPlan == 'free') {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  icon: Icon(
                                                    Icons.payment_rounded,
                                                  ),
                                                  iconColor: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                  title: const Text(
                                                      'Upgrade to use templates'),
                                                  titleTextStyle: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                  content: const Text(
                                                    'To use custom templates, you need to be on either the Pro or the Lifetime subscription plans',
                                                  ),
                                                  contentTextStyle: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  actions: [
                                                    // Button to cancel and close the dialog box
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      style: const ButtonStyle(
                                                        foregroundColor:
                                                            WidgetStatePropertyAll(
                                                                Colors.red),
                                                      ),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    // Button to redirect to the subscriptions page
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UpgradeSubscriptionScreen()));
                                                      },
                                                      style: ButtonStyle(
                                                        foregroundColor:
                                                            WidgetStatePropertyAll(
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                      ),
                                                      child:
                                                          const Text('Upgrade'),
                                                    ),
                                                  ],
                                                );
                                              });
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CustomTemplatesScreen()));
                                        }
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            'templates',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            size: 14,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8)
                              ],
                            ),
                          );
                        },
                      );
                    } else if (currentPageIndex == 3) {
                      // All objects adding sheet
                      showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          useSafeArea: true,
                          builder: (context) => TypesOfObjects());
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Create')),
            ),
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
            onDestinationSelected: (currentPageIndex) =>
                setState(() => this.currentPageIndex = currentPageIndex),
          ),
          // When the sideBar is enabled or largened
          Expanded(
              child: Padding(
            padding:
                // Platform.isWindows
                // ?
                _extended!
                    ? EdgeInsetsGeometry.symmetric(horizontal: 120)
                    : const EdgeInsets.symmetric(horizontal: 220.0),
            // : const EdgeInsets.all(0.0),
            child: screens[currentPageIndex],
          ))
          // :
          // // When the sideBar is disabled or shortened
          // Expanded(
          //     child: SizedBox(
          //         width: MediaQuery.of(context).size.width,
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(horizontal: 150.0),
          //           child: screens[currentPageIndex],
          //         )).animate().fade(),
          //   )
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
