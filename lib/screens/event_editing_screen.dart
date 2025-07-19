import 'package:bloom/components/mybuttons.dart';
import 'package:bloom/components/mytextfield.dart';
import 'package:bloom/notifications/notification.dart';
import 'package:bloom/responsive/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class EventEditingScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventNotes;
  final DateTime eventStartDateTime;
  final DateTime eventEndDateTime;
  final int eventUniqueId;
  final Color eventColorCode;
  const EventEditingScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.eventNotes,
    required this.eventStartDateTime,
    required this.eventEndDateTime,
    required this.eventUniqueId,
    required this.eventColorCode,
  });

  @override
  State<EventEditingScreen> createState() => _EventEditingScreenState();
}

class _EventEditingScreenState extends State<EventEditingScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController eventNameController;
  late TextEditingController eventDetailsController;
  final eventNameFocusNode = FocusNode();
  final eventDetailsFocusNode = FocusNode();
  late DateTime startDate;
  late TimeOfDay startTime;
  late DateTime endDate;
  late TimeOfDay endTime;
  Color? colorCode = const Color(0xFF69F0AE);
  DateTime? eventStartDateTime;
  DateTime? eventEndDateTime;

  // Init method to initialize
  @override
  void initState() {
    super.initState();
    startDate = widget.eventStartDateTime;
    eventNameController = TextEditingController(text: widget.eventName);
    eventDetailsController = TextEditingController(text: widget.eventNotes);
    endDate = widget.eventEndDateTime;
    colorCode = widget.eventColorCode;
    startTime = TimeOfDay.fromDateTime(DateTime(
        widget.eventStartDateTime.year,
        widget.eventStartDateTime.month,
        widget.eventStartDateTime.day,
        widget.eventStartDateTime.hour,
        0,
        0));
    endTime = TimeOfDay.fromDateTime(DateTime(
        widget.eventEndDateTime.year,
        widget.eventEndDateTime.month,
        widget.eventEndDateTime.day,
        widget.eventEndDateTime.hour + 1,
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
    // Create and merge the start date, time into one variable
    eventStartDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute, startDate.second);
    // Create and merge the end date, time into one variable
    eventEndDateTime = DateTime(endDate.year, endDate.month, endDate.day,
        endTime.hour, endTime.minute, endDate.second);
    // Add to firestore
    firestore.doc(widget.eventId).update(
      {
        'eventName': eventNameController.text.isEmpty
            ? widget.eventName
            : eventNameController.text.isNotEmpty &&
                    eventNameController.text != widget.eventName
                ? eventNameController.text
                : widget.eventName,
        'eventNotes': eventDetailsController.text.isEmpty
            ? widget.eventNotes
            : eventDetailsController.text.isNotEmpty &&
                    eventDetailsController.text != widget.eventNotes
                ? eventDetailsController.text
                : widget.eventNotes,
        'eventStartDateTime': eventStartDateTime,
        'eventEndDateTime': eventEndDateTime,
        'eventColorCode':
            widget.eventColorCode.toHexString() == colorCode!.toHexString()
                ? widget.eventColorCode
                : colorCode!.toHexString(),
        'eventUniqueId': widget.eventUniqueId,
        'isAttended': false,
      },
    );
    // Close modal sheet after
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Editing event'),
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.width > mobileWidth
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Name',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              // Event name typing field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                    controller: eventNameController,
                    focusNode: eventNameFocusNode,
                    hintText: widget.eventName,
                    obscureText: false,
                    autoFocus: false,
                    textInputType: TextInputType.text),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Notes',
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 5),
              // Event notes typing field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: MyTextfield(
                    controller: eventDetailsController,
                    focusNode: eventDetailsFocusNode,
                    hintText:
                        widget.eventNotes == '' ? 'Notes' : widget.eventNotes,
                    obscureText: false,
                    autoFocus: false,
                    textInputType: TextInputType.text),
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
              // Group the start, end and color code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Event start date and time
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Starts',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            // Start Event date selection field
                            Flexible(
                              child: ExtraOptionsButton(
                                outerPadding: const EdgeInsets.only(left: 14),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8)),
                                label: DateFormat('dd-MM-yy').format(startDate),
                                textAlign: TextAlign.center,
                                onTap: () {
                                  selectDate(true);
                                },
                              ),
                            ),
                            // Start Event time selection field
                            Flexible(
                              child: ExtraOptionsButton(
                                outerPadding: const EdgeInsets.only(left: 14),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8)),
                                label: startTime.format(context),
                                textAlign: TextAlign.center,
                                onTap: () {
                                  selectTime(true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Event end date and time
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Ends',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            // End Event date selection field
                            Flexible(
                              child: ExtraOptionsButton(
                                outerPadding: const EdgeInsets.only(left: 14),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8)),
                                label: DateFormat('dd-MM-yy').format(endDate),
                                onTap: () {
                                  selectDate(false);
                                },
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // End Event time selection field
                            Flexible(
                              child: ExtraOptionsButton(
                                outerPadding: const EdgeInsets.only(left: 14),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8)),
                                label: endTime.format(context),
                                textAlign: TextAlign.center,
                                onTap: () {
                                  selectTime(false);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Color picker for events
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
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
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      title: const Text('Select color'),
                                      titleTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400),
                                      content: SingleChildScrollView(
                                        child: MaterialPicker(
                                          pickerColor: colorCode!,
                                          onColorChanged: changeColor,
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                      Theme.of(context)
                                                          .primaryColor)),
                                          child: Text(
                                            'Select',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
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
                                    color: colorCode,
                                    borderRadius: BorderRadius.circular(1000)),
                              ),
                            )
                          ],
                        ),
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
              // Submit button
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
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
                    addEventToFirebase();
                    // Add notification scheduling here
                    // Event start notification
                    await NotificationService.scheduleEventsNotification(
                      widget.eventUniqueId,
                      'Event start reminder!',
                      eventNameController.text.trim(),
                      startDateTime,
                      Importance.defaultImportance,
                      Priority.defaultPriority,
                    );
                    // Event end notification
                    await NotificationService.scheduleEventsNotification(
                      widget.eventUniqueId,
                      'Event end reminder!',
                      eventNameController.text.trim(),
                      endDateTime,
                      Importance.defaultImportance,
                      Priority.defaultPriority,
                    );
                    // Show confirmation that task is added
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        margin: const EdgeInsets.all(6),
                        behavior: SnackBarBehavior.floating,
                        showCloseIcon: true,
                        closeIconColor:
                            Theme.of(context).textTheme.bodyMedium?.color,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        content: Text(
                          'Event succesfully updated!',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        'Update event',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 64,
              )
            ],
          ),
        ),
      ),
    );
  }
}
