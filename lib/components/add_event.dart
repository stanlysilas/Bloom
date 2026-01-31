import 'package:bloom/components/bloom_buttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

// Add event modal bottom sheet
class AddEventModalSheet extends StatefulWidget {
  final DateTime currentDateTime;
  const AddEventModalSheet({super.key, required this.currentDateTime});

  @override
  State<AddEventModalSheet> createState() => _AddEventModalSheetState();
}

class _AddEventModalSheetState extends State<AddEventModalSheet> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  final eventNameController = TextEditingController();
  final eventDetailsController = TextEditingController();
  final eventNameFocusNode = FocusNode();
  final eventDetailsFocusNode = FocusNode();
  late DateTime startDate;
  late TimeOfDay startTime;
  late DateTime endDate;
  late TimeOfDay endTime;
  Color? colorCode = const Color(0xFF5E7CE2);
  int? uniqueId;
  DateTime? eventStartDateTime;
  DateTime? eventEndDateTime;

  // Initstate for initializing methods and variables
  @override
  void initState() {
    super.initState();
    startDate = widget.currentDateTime;
    endDate = widget.currentDateTime;
    startTime = TimeOfDay.fromDateTime(DateTime(
        widget.currentDateTime.year,
        widget.currentDateTime.month,
        widget.currentDateTime.day,
        widget.currentDateTime.hour,
        0,
        0));
    endTime = TimeOfDay.fromDateTime(DateTime(
        widget.currentDateTime.year,
        widget.currentDateTime.month,
        widget.currentDateTime.day,
        widget.currentDateTime.hour + 1,
        0,
        0));
  }

  // Date picker for events
  Future<void> selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Time picker for events
  Future<void> selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  // Add event to firebase firestore logic
  void addEventToFirebase() async {
    final firestore = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('events');
    // Generate docId for this event
    final eventDocId = firestore.doc().id;
    // Create and merge the start date, time into one variable
    eventStartDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute, startDate.second);
    // Create and merge the end date, time into one variable
    eventEndDateTime = DateTime(endDate.year, endDate.month, endDate.day,
        endTime.hour, endTime.minute, endDate.second);
    // Generate a uniqueId for notifications purpose
    uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    // Add to firestore
    if (eventNameController.text.isNotEmpty) {
      firestore.doc(eventDocId).set(
        {
          'eventName': eventNameController.text.trim(),
          'eventNotes': eventDetailsController.text.trim(),
          'eventStartDateTime': eventStartDateTime,
          'eventEndDateTime': eventEndDateTime,
          'eventColorCode': colorCode!.toHexString(),
          'eventId': eventDocId,
          'eventUniqueId': uniqueId ?? 0,
          'isAttended': false,
        },
      );
    }
    // Close modal sheet after
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.width > mobileWidth
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              // Event name heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Name',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // Event name text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                  controller: eventNameController,
                  focusNode: eventNameFocusNode,
                  hintText: "Attend the Zoom meeting",
                  obscureText: false,
                  textInputType: TextInputType.text,
                  autoFocus: false,
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Event notes heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Notes',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              // Event details text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                  controller: eventDetailsController,
                  focusNode: eventDetailsFocusNode,
                  hintText: 'Prepare a PPT for the meeting',
                  obscureText: false,
                  textInputType: TextInputType.text,
                  autoFocus: false,
                  maxLines: 6,
                  minLines: 1,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Group the start, end and color code
              // Event other heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Other',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Event start date and time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Starts',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          // Start Event date selection field
                          Flexible(
                            child: BloomMaterialListTile(
                              outerPadding: const EdgeInsets.all(0),
                              innerPadding: EdgeInsets.all(6),
                              icon: SizedBox(),
                              iconLabelSpace: 0,
                              useSpacer: false,
                              labelStyle: TextStyle(fontSize: 16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              label: DateFormat('dd-MM-yy').format(startDate),
                              textAlign: TextAlign.center,
                              onTap: () {
                                selectDate(true);
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Start Event time selection field
                          Flexible(
                            child: BloomMaterialListTile(
                              outerPadding: const EdgeInsets.all(0),
                              innerPadding: EdgeInsets.all(6),
                              icon: SizedBox(),
                              iconLabelSpace: 0,
                              useSpacer: false,
                              labelStyle: TextStyle(fontSize: 16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              label: startTime.format(context),
                              textAlign: TextAlign.center,
                              onTap: () {
                                selectTime(true);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Event end date and time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Ends',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          // End Event date selection field
                          Flexible(
                            child: BloomMaterialListTile(
                              outerPadding: const EdgeInsets.all(0),
                              innerPadding: EdgeInsets.all(6),
                              icon: SizedBox(),
                              iconLabelSpace: 0,
                              useSpacer: false,
                              labelStyle: TextStyle(fontSize: 16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              label: DateFormat('dd-MM-yy').format(endDate),
                              onTap: () {
                                selectDate(false);
                              },
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // End Event time selection field
                          Flexible(
                            child: BloomMaterialListTile(
                              outerPadding: const EdgeInsets.all(0),
                              innerPadding: EdgeInsets.all(6),
                              icon: SizedBox(),
                              iconLabelSpace: 0,
                              useSpacer: false,
                              labelStyle: TextStyle(fontSize: 16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              label: endTime.format(context),
                              textAlign: TextAlign.center,
                              onTap: () {
                                selectTime(false);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Color picker for events
                      Row(
                        children: [
                          const Text(
                            'Color code',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              // Show Color picker dialog for event color
                              void changeColor(Color color) {
                                setState(() => colorCode = color);
                              }

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Select color'),
                                    content: SingleChildScrollView(
                                      child: MaterialPicker(
                                        pickerColor: colorCode!,
                                        onColorChanged: changeColor,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text('Select'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: colorCode, shape: BoxShape.circle),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (MediaQuery.of(context).size.width > mobileWidth)
                const SizedBox(
                  height: 24,
                ),
              if (MediaQuery.of(context).size.width < mobileWidth)
                const Spacer(),
              // Submit / add event button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
                child: InkWell(
                  onTap: () async {
                    // Create and merge the start date, time into one variable
                    DateTime startDateTime = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day,
                        startTime.hour,
                        startTime.minute,
                        startDate.second);
                    // Create and merge the start date, time into one variable
                    DateTime endDateTime = DateTime(
                        endDate.year,
                        endDate.month,
                        endDate.day,
                        endTime.hour,
                        endTime.minute,
                        endDate.second);
                    // Logic to add event to firebase firestore
                    addEventToFirebase();
                    // Schedule notifications
                    // Event start notification
                    await NotificationService.scheduleEventsNotification(
                      uniqueId!,
                      'Event start reminder!',
                      eventNameController.text.trim(),
                      startDateTime,
                      Importance.defaultImportance,
                      Priority.defaultPriority,
                    );
                    // Event end notification
                    await NotificationService.scheduleEventsNotification(
                      uniqueId!,
                      'Event end reminder!',
                      eventNameController.text.trim(),
                      endDateTime,
                      Importance.defaultImportance,
                      Priority.defaultPriority,
                    );
                    // Show confirmation of added
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        margin: const EdgeInsets.all(6),
                        behavior: SnackBarBehavior.floating,
                        showCloseIcon: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        content: Text('Event succesfully scheduled!'),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.maxFinite,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text('Add new event',
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                ),
              ),
              const SizedBox(height: 52)
            ],
          ),
        ),
      ),
    );
  }
}
