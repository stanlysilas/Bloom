import 'package:flutter/material.dart';

class ProfilePictureDialog extends StatefulWidget {
  const ProfilePictureDialog({super.key});

  @override
  State<ProfilePictureDialog> createState() => _ProfilePictureDialogState();
}

String profilePicture = '';

class _ProfilePictureDialogState extends State<ProfilePictureDialog> {
  // Variables
  int? selectedIndex;
  // Profile Pictures
  List<String> profilePictures = [
    'assets/profile_pictures/Profile_Picture_Male.png',
    'assets/profile_pictures/Profile_Picture_Female.png'
  ];
  // Names of Profile Pictures
  List<String> labels = ['Default Male', 'Default Female'];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: 400,
        width: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text(
              'Choose a profile picture',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            GridView.builder(
              itemCount: profilePictures.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 200,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) => Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: selectedIndex == index
                            ? Theme.of(context).primaryColorDark
                            : Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: Image.asset(
                          profilePictures[index].toString(),
                          scale: 14,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    labels[index],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    selectedIndex == index ? 'Selected' : '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(profilePictures[selectedIndex!]);
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Select',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
