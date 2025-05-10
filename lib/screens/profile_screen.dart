// import 'package:bloom/authentication_screens/change_email_screen.dart';
import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/components/overview_data.dart';
import 'package:bloom/components/profile_pic.dart';
import 'package:bloom/screens/detailed_analytics_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  final bool? isImageNetwork;
  final String? profilePicture;
  final String? userName;
  final String uid;
  final String? email;
  final ProfileMode mode;
  const ProfileScreen({
    super.key,
    required this.isImageNetwork,
    required this.profilePicture,
    required this.userName,
    required this.uid,
    required this.email,
    required this.mode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Enum for different modes of showing profile screen
enum ProfileMode { display, edit }

class _ProfileScreenState extends State<ProfileScreen> {
  // Required variables and controllers
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late ProfileMode mode;
  final user = FirebaseAuth.instance.currentUser;
  String? selectedProfilePicture;
  int? numberOfCompletedTasks;
  int? numberOfUncompletedTasks;
  int? numberOfEntriesInYear;
  int? completedTasksInYear;
  int? attendedEventsInYear;
  String? subscriptionPlan;
  late Map<DateTime, int> completedTasksByDate = {};

  // Method to initialize the required variables and methods
  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController(text: widget.userName);
    emailController = TextEditingController(text: widget.email);
    mode = widget.mode;
    dataOverviewCheck();
    checkSubscription();
    getCompletedTaskCountsByDate();
  }

  // check the completed task dates and add it to the variable
  Future<Map<DateTime, int>> getCompletedTaskCountsByDate() async {
    if (user == null) {
      return {};
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .collection('tasks')
        .where('isCompleted', isEqualTo: true)
        .get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final Timestamp? completionTimestamp =
          doc.data()['taskDateTime'] as Timestamp?;

      if (completionTimestamp != null) {
        // Convert Timestamp to DateTime and remove the time component
        final DateTime completionDate = completionTimestamp.toDate();
        final DateTime dateOnly = DateTime(
            completionDate.year, completionDate.month, completionDate.day);

        // Update the count for this date
        completedTasksByDate[dateOnly] =
            (completedTasksByDate[dateOnly] ?? 0) + 1;
      }
    }

    return completedTasksByDate;
  }

  // Check the subscription plan of the user
  void checkSubscription() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final plan = data?['subscriptionPlan'];

        setState(() {
          if (plan == null || plan == 'free') {
            subscriptionPlan = 'free';
          } else if (plan == 'pro') {
            subscriptionPlan = 'pro';
          } else {
            subscriptionPlan = 'ultra';
          }
        });
      }
    } catch (e) {
      //
    }
  }

  // Method to save the changes to firebase after editing
  void saveEditChanges() {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    userRef.update({
      'userName': userNameController.text.trim(),
      'profilePicture': selectedProfilePicture,
      'isImageNetwork': false,
    });
  }

  void dataOverviewCheck() {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .count()
          .get()
          .then((value) {
        setState(() {
          numberOfCompletedTasks = value.count;
        });
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .count()
          .get()
          .then((value) {
        setState(() {
          numberOfUncompletedTasks = value.count;
        });
      });
      // Get the current year
      DateTime now = DateTime.now();
      DateTime startOfYear = DateTime(now.year, 1, 1); // Start of the year
      DateTime endOfYear = DateTime(now.year + 1, 1, 1)
          .subtract(const Duration(seconds: 1)); // End of the year

      // Query the entries within the current year
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .where('dateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('dateTime', isLessThanOrEqualTo: endOfYear)
          .count()
          .get()
          .then((value) {
        setState(() {
          numberOfEntriesInYear = value.count;
        });
      });

      // Query the completed tasks within current year
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('taskDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('taskDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isCompleted', isEqualTo: true)
          .count()
          .get()
          .then((value) {
        setState(() {
          completedTasksInYear = value.count;
        });
      });

      // Query the events attended within current year
      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('eventStartDateTime', isGreaterThanOrEqualTo: startOfYear)
          .where('eventEndDateTime', isLessThanOrEqualTo: endOfYear)
          .where('isAttended', isEqualTo: true)
          .count()
          .get()
          .then((value) {
        setState(() {
          attendedEventsInYear = value.count;
        });
      });
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: mode == ProfileMode.display
            ? const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              )
            : const Text(
                'Edit profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
        actions: [
          mode == ProfileMode.display
              ? IconButton(
                  onPressed: () async {
                    //Logout process
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: const EdgeInsets.all(6),
                          behavior: SnackBarBehavior.floating,
                          showCloseIcon: true,
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          content: Text(
                            'Encountered an error while logging out. Error code: ${e.toString()}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      mode = ProfileMode.display;
                    });
                  },
                  icon: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
        ],
      ),
      body: mode == ProfileMode.display
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          widget.isImageNetwork == true &&
                                  widget.isImageNetwork != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: Hero(
                                    tag: 'network_image_hero',
                                    child: Image.network(
                                      widget.profilePicture ??
                                          'assets/profile_pictures/Profile_Picture_Male.png',
                                      scale: 7,
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: 'asset_image_hero',
                                  child: Image.asset(
                                    widget.profilePicture ??
                                        'assets/profile_pictures/Profile_Picture_Male.png',
                                    scale: 12,
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Username of the user
                          if (widget.userName != null || widget.userName != '')
                            Hero(
                              tag: 'userName_hero',
                              child: Text(
                                widget.userName ?? user!.email!.substring(0, 8),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          // Email of the user
                          if (widget.email != null || widget.email != '')
                            SelectableText(
                              widget.email ?? user!.email!,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Button to edit the account/profile
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              setState(() {
                                mode = ProfileMode.edit;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Edit profile',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Yearly stats are displayed here
                            const Text(
                              'Yearly stats',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: NumberOfEntriesInYear(
                                    numberOfEntriesInYear:
                                        numberOfEntriesInYear ?? 0,
                                  ),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailedAnalyticsScreen(
                                                      completedTasksPerDay:
                                                          completedTasksByDate)));
                                    },
                                    child: NumberOfTasksInYear(
                                      completedTasksInYear:
                                          completedTasksInYear ?? 0,
                                    ),
                                  ),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: NumberOfEventsInYear(
                                    attendedEventsInYear:
                                        attendedEventsInYear ?? 0,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                      child: Divider(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // // Heading for the content section
                    // const Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 12.0),
                    //   child: Text(
                    //     'Content',
                    //     style: TextStyle(fontSize: 16),
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    // Analytics button
                    ExtraOptionsButton(
                      showTag: subscriptionPlan == 'free' ? true : false,
                      icon: const Icon(Iconsax.graph),
                      iconLabelSpace: 8,
                      label: 'Analytics',
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                      innerPadding: const EdgeInsets.all(12),
                      onTap: () {
                        if (subscriptionPlan == 'pro' ||
                            subscriptionPlan == 'ultra') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DetailedAnalyticsScreen(
                                completedTasksPerDay: completedTasksByDate,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              margin: const EdgeInsets.all(6),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text(
                                'Analytics are only available with Pro and Ultra subscriptions',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  InkWell(
                    onTap: () async {
                      final selectedPicture = await showDialog<String>(
                        context: context,
                        builder: (context) => const ProfilePictureDialog(),
                      );
                      if (selectedPicture != null) {
                        setState(() {
                          selectedProfilePicture = selectedPicture;
                        });
                      }
                    },
                    child: selectedProfilePicture != null
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.asset(
                                selectedProfilePicture!,
                                scale: 14,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.edit,
                                    size: 16,
                                    color: Theme.of(context).primaryColorLight),
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              widget.isImageNetwork == true &&
                                      widget.isImageNetwork != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(1000),
                                      child: Image.network(
                                        widget.profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male.png',
                                        scale: 8,
                                      ),
                                    )
                                  : Image.asset(
                                      widget.profilePicture ??
                                          'assets/profile_pictures/Profile_Picture_Male.png',
                                      scale: 14,
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.edit,
                                    size: 16,
                                    color: Theme.of(context).primaryColorLight),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // New username field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      MyTextfield(
                        controller: userNameController,
                        hintText: 'New Username',
                        obscureText: false,
                        textInputType: TextInputType.name,
                        autoFocus: false,
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     const Text(
                  //       'Email',
                  //       style: TextStyle(fontWeight: FontWeight.w600),
                  //     ),
                  //     const SizedBox(
                  //       height: 6,
                  //     ),
                  //     // Go to Email change screen
                  //     InkWell(
                  //       borderRadius: BorderRadius.circular(10),
                  //       onTap: () => Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //               builder: (context) => ChangeEmailScreen())),
                  //       child: Container(
                  //         width: double.maxFinite,
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 8, vertical: 12),
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).primaryColorLight,
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         child: Row(
                  //           mainAxisAlignment:
                  //               MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Text(
                  //               widget.email!,
                  //               style: const TextStyle(fontSize: 16),
                  //             ),
                  //             const Icon(Iconsax.arrow_right)
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 50,
                  ),
                  // Confirm changes to account and save
                  InkWell(
                    onTap: () {
                      try {
                        if ((userNameController.text.trim() !=
                                widget.userName) ||
                            selectedProfilePicture != widget.profilePicture) {
                          saveEditChanges();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              margin: const EdgeInsets.all(6),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text(
                                'Changes saved succesfully.',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color),
                              ),
                            ),
                          );
                          setState(() {
                            mode = ProfileMode.display;
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: const EdgeInsets.all(6),
                            behavior: SnackBarBehavior.floating,
                            showCloseIcon: true,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text(
                              'Saving changes failed. Error code: ${e.toString()}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
