import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  // Required variables
  final user = FirebaseAuth.instance.currentUser;
  final feedbackController = TextEditingController();
  int userRating = 1;
  bool isSubmitting = false;
  List<String> userRatingStrings = [
    'Very bad',
    'Bad',
    'Ok',
    'Good',
    'Very good',
  ];
  List<String> userRatingIcons = [
    '😡',
    '☹️',
    '😐',
    '🙂',
    '🤩',
  ];
  // Init method
  @override
  void initState() {
    super.initState();
    checkUserRating();
  }

  // Method to check if the user rated or not
  void checkUserRating() async {
    await FirebaseFirestore.instance
        .collection('ratings')
        .doc(user?.uid)
        .get()
        .then((value) async {
      if (value.exists && value.data()!.containsKey('userRating')) {
        setState(() {
          userRating = value['userRating'];
        });
      } else {
        userRating = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Heading for rating
      title:
          // User rating icons
          Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
        ),
        child: Text(
          userRatingIcons[userRating - 1],
          style: const TextStyle(fontSize: 20),
        ),
      ),
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // User rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: InkWell(
                      onTap: () {
                        // Set the userRating to the index tapped and draw the filled stars
                        setState(() {
                          userRating = index + 1;
                        });
                      },
                      child: Icon(
                        index < userRating
                            ? Icons.star_rate_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // User rating strings
            Text(
              userRatingStrings[userRating - 1],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        // A submit button for submitting the feedback and rating
        TextButton(
          onPressed: () async {
            setState(() {
              isSubmitting = true;
            });
            // Save the rating to the user's account for now
            await FirebaseFirestore.instance
                .collection('ratings')
                .doc(user?.uid)
                .set({
              'email': user?.email,
              'uid': user?.uid,
              'userRating': userRating,
              'userRatingString': userRatingStrings[userRating - 1],
            });
            // Close the dialog
            Navigator.pop(context);
          },
          child: isSubmitting
              ? CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                )
              : Text(
                  'Submit',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
        )
      ],
    );
  }
}
