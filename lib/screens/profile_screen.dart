import 'package:bloom/authentication_screens/signup_screen.dart';
import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/components/overview_data.dart';
import 'package:bloom/components/profile_pic.dart';
// import 'package:bloom/screens/privacy_password_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final userNameFocusNode = FocusNode();
  late TextEditingController emailController;
  late ProfileMode mode;
  final user = FirebaseAuth.instance.currentUser;
  String? selectedProfilePicture;
  int? numberOfCompletedTasks;
  int? numberOfUncompletedTasks;
  int? numberOfEntries;
  int? completedTasks;
  int? attendedEvents;
  String? privacyPassword = '';
  bool? isNotificationEnabled = false;
  String? profilePicture;

  // Method to initialize the required variables and methods
  @override
  void initState() {
    super.initState();
    checkPrivacyPassword();
    userNameController = TextEditingController(text: widget.userName);
    emailController = TextEditingController(text: widget.email);
    mode = widget.mode;
    profilePicture = widget.profilePicture;
    dataOverviewCheck();
    isNotificationEnabledCheck();
  }

  // Check the Privacy Password of the user
  void checkPrivacyPassword() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final plan = data?['privacyPassword'];

        setState(() {
          if (plan != null) {
            privacyPassword = data?['privacyPassword'];
          } else {
            privacyPassword = '';
          }
        });
      }
    } catch (e) {
      //
    }
  }

  /// Method to save the changes to firebase after editing
  void saveEditChanges() {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user?.uid);
    userRef.update({
      'userName': userNameController.text.trim(),
      'profilePicture': selectedProfilePicture,
      'isImageNetwork': false,
    });
  }

  /// Check if the notification permission is granted or not
  void isNotificationEnabledCheck() async {
    final granted = await Permission.notification.isGranted;
    if (granted == true) {
      setState(() {
        isNotificationEnabled = true;
      });
    } else {
      setState(() {
        isNotificationEnabled = false;
      });
    }
  }

  /// Check the data of the user for all the created objects
  void dataOverviewCheck() async {
    try {
      // 1. Get the count of Notes and Books simultaneously
      final notesFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('entries')
          .count()
          .get();

      final booksFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('books')
          .count()
          .get();

      // Use await to wait for both futures to complete
      final notesSnapshot = await notesFuture;
      final booksSnapshot = await booksFuture;

      // Use setState only once after all data is ready
      setState(() {
        final numberOfNotes = notesSnapshot.count;
        final numberOfBooks = booksSnapshot.count;

        // Now the values are guaranteed to be set
        numberOfEntries = numberOfNotes! + numberOfBooks!;
      });

      // 2. Fetch other counts (can also be done with await)
      final completedTasksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .count()
          .get();

      final uncompletedTasksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .count()
          .get();

      final attendedEventsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('events')
          .where('isAttended', isEqualTo: true)
          .count()
          .get();

      // Update all state variables together for better performance
      setState(() {
        numberOfCompletedTasks = completedTasksSnapshot.count;
        numberOfUncompletedTasks = uncompletedTasksSnapshot.count;
        completedTasks = completedTasksSnapshot.count;
        attendedEvents = attendedEventsSnapshot.count;
      });
    } catch (e) {
      // Handle error (e.g., print(e), show a message to the user)
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
            ? const Text('Profile')
            : const Text('Edit profile'),
      ),
      body: mode == ProfileMode.display
          ? SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          widget.isImageNetwork == true &&
                                  widget.isImageNetwork != null
                              ? Hero(
                                  tag: 'network_image_hero',
                                  child: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withAlpha(50),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, 6))
                                    ], borderRadius: BorderRadius.circular(16)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        widget.profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male_1.png',
                                        frameBuilder: (context, child, frame,
                                            wasSynchronouslyLoaded) {
                                          if (frame == null) {
                                            return child;
                                          }
                                          return child;
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainer),
                                            child: CircularProgressIndicator(
                                              year2023: false,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainer,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Text(
                                              '😿',
                                              style: TextStyle(fontSize: 42),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: 'asset_image_hero',
                                  child: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withAlpha(50),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, 6))
                                    ], borderRadius: BorderRadius.circular(16)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        widget.profilePicture ??
                                            'assets/profile_pictures/Profile_Picture_Male_1.png',
                                        scale: 12,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          // Username of the user
                          if (widget.userName != null || widget.userName != '')
                            Hero(
                              tag: 'userName_hero',
                              transitionOnUserGestures: true,
                              placeholderBuilder: (context, heroSize, child) {
                                return Text(
                                  user!.email!.substring(0, 8),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                              child: Text(
                                  widget.userName ??
                                      user!.email!.substring(0, 8),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                          // Email of the user
                          if (widget.email != null || widget.email != '')
                            SelectableText(
                              widget.email ?? user!.email!,
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: NumberOfEntries(
                                numberOfEntries: numberOfEntries ?? 0,
                              ),
                            ),
                            Expanded(
                              child: NumberOfTasks(
                                completedTasks: completedTasks ?? 0,
                              ),
                            ),
                            Expanded(
                              child: NumberOfEvents(
                                attendedEvents: attendedEvents ?? 0,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Other Options Block
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Column(
                        children: [
                          // Edit Profile Button
                          BloomMaterialListTile(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4)),
                            icon: Icon(Icons.person,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            label: 'Edit Profile',
                            subLabel: 'Change your profile details',
                            iconLabelSpace: 8,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                            innerPadding: const EdgeInsets.all(16),
                            outerPadding: EdgeInsets.symmetric(vertical: 1),
                            onTap: () {
                              setState(() {
                                mode = ProfileMode.edit;
                              });
                            },
                            endIcon:
                                const Icon(Icons.keyboard_arrow_right_rounded),
                          ),
                          // Notifications Toggle Button
                          BloomMaterialListTile(
                            icon: Icon(Icons.notifications_active,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                            label: 'Notifications',
                            subLabel:
                                'Reminders, updates and other notifications',
                            iconLabelSpace: 8,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                            innerPadding: const EdgeInsets.all(16),
                            outerPadding: EdgeInsets.symmetric(vertical: 1),
                            endIcon: Switch(
                                value: isNotificationEnabled!,
                                onChanged: (value) async {
                                  if (isNotificationEnabled == false) {
                                    await Permission.notification.request();
                                  } else {
                                    // Confirmation dialog to turn off notifications for reminders
                                    showAdaptiveDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog.adaptive(
                                            icon: Icon(
                                                Icons.warning_amber_rounded),
                                            iconColor: Colors.red,
                                            title: Text(
                                              'Disable notifications?',
                                            ),
                                            content: Text(
                                              "Do you want to disable all notifications? You won't be able to receive any reminders, updates and more",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  // Cancel and close the dialog
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Cancel',
                                                ),
                                              ),
                                              TextButton(
                                                style: ButtonStyle(
                                                    foregroundColor:
                                                        WidgetStatePropertyAll(
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .error)),
                                                onPressed: () async {
                                                  // Go to settings
                                                  await openAppSettings();
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Turn off'),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                }),
                          ),
                          // Privacy Password Setup/Modify Button
                          // BloomMaterialListTile(
                          //   icon: Icon(Icons.password,
                          //       color: Theme.of(context)
                          //           .colorScheme
                          //           .onSecondaryContainer),
                          //   label: privacyPassword != ''
                          //       ? 'Manage Privacy Password'
                          //       : 'Setup Privacy Password',
                          //   subLabel: 'Password for locking/unlocking objects',
                          //   iconLabelSpace: 8,
                          //   labelStyle: const TextStyle(
                          //       fontWeight: FontWeight.w500, fontSize: 18),
                          //   innerPadding: const EdgeInsets.all(16),
                          //   outerPadding: EdgeInsets.symmetric(vertical: 1),
                          //   onTap: () {
                          //     // TODO: PERFORM THE NEEDED OPERATIONS FOR CREATING A PASSWORD
                          //     // CURRENTLY ONLY GOES TO THE SCREEN
                          //     Navigator.of(context).push(MaterialPageRoute(
                          //         builder: (context) =>
                          //             PrivacyPasswordScreen()));
                          //   },
                          //   endIcon:
                          //       const Icon(Icons.keyboard_arrow_right_rounded),
                          // ),
                          // Logout Button
                          BloomMaterialListTile(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4)),
                            icon: Icon(Icons.logout,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            label: 'Logout',
                            subLabel: 'Sign out from your account',
                            iconLabelSpace: 8,
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                            innerPadding: const EdgeInsets.all(16),
                            outerPadding: EdgeInsets.symmetric(vertical: 1),
                            onTap: () {
                              // Log the user out of the current session.
                              //Logout process
                              try {
                                showAdaptiveDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog.adaptive(
                                        icon: const Icon(Icons.logout),
                                        iconColor:
                                            Theme.of(context).colorScheme.error,
                                        title: Text('Logout?'),
                                        content: const Text(
                                            "Are you sure that you want to logout of your account?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // Cancel and close the dialog
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            style: ButtonStyle(
                                                foregroundColor:
                                                    WidgetStatePropertyAll(
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .error)),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              // Logout of the app account
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignupScreen(),
                                                ),
                                              );
                                            },
                                            child: Text('Logout'),
                                          ),
                                        ],
                                        actionsPadding:
                                            const EdgeInsets.all(10),
                                        actionsAlignment: MainAxisAlignment.end,
                                      );
                                    });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    margin: const EdgeInsets.all(6),
                                    behavior: SnackBarBehavior.floating,
                                    showCloseIcon: true,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    content: Text(
                                        'Encountered an error while logging out. Error code: ${e.toString()}'),
                                  ),
                                );
                              }
                            },
                            endIcon:
                                const Icon(Icons.keyboard_arrow_right_rounded),
                          ),
                        ],
                      ),
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
                    borderRadius: BorderRadius.circular(100),
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
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withAlpha(50),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    selectedProfilePicture!,
                                    scale: 10,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.edit),
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              widget.isImageNetwork == true &&
                                      widget.isImageNetwork != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withAlpha(50),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          widget.profilePicture ??
                                              'assets/profile_pictures/Profile_Picture_Male_1.png',
                                          scale: 1,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                '😿',
                                                style: TextStyle(fontSize: 42),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withAlpha(50),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          widget.profilePicture ??
                                              'assets/profile_pictures/Profile_Picture_Male_1.png',
                                          scale: 10,
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.edit),
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
                        focusNode: userNameFocusNode,
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
                  if (userNameController.text != widget.userName ||
                      profilePicture != selectedProfilePicture)
                    // Confirm changes to account and save
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        try {
                          // TODO: ADD A DIALOG TO ASK FOR CONFIRM IF ANYTHING IS CHANGED
                          setState(() {
                            mode = ProfileMode.display;
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              margin: const EdgeInsets.all(6),
                              behavior: SnackBarBehavior.floating,
                              showCloseIcon: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text(
                                  'Failed to discard changes. Error code: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Discard Changes',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  if (userNameController.text != widget.userName ||
                      profilePicture != selectedProfilePicture)
                    const SizedBox(height: 24),
                  // Confirm changes to account and save
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              content: Text('Changes saved succesfully.'),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            content: Text(
                                'Saving changes failed. Error code: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.maxFinite,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
