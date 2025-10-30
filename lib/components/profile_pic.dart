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
    'assets/profile_pictures/Profile_Picture_Male_1.png',
    'assets/profile_pictures/Profile_Picture_Female_1.png',
    'assets/profile_pictures/Profile_Picture_Male_2.png',
    'assets/profile_pictures/Profile_Picture_Female_2.png',
    'assets/profile_pictures/Profile_Picture_Male_3.png',
    'assets/profile_pictures/Profile_Picture_Female_3.png',
    'assets/profile_pictures/Profile_Picture_Male_4.png',
    'assets/profile_pictures/Profile_Picture_Female_4.png',
    'assets/profile_pictures/Profile_Picture_Male_5.png',
    'assets/profile_pictures/Profile_Picture_Female_5.png',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Choose a profile picture'),
      content: Container(
        height: 250,
        width: MediaQuery.of(context).size.width / 2,
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: profilePictures.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 130,
          ),
          shrinkWrap: true,
          itemBuilder: (context, index) => Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: selectedIndex == index
                        ? Theme.of(context).colorScheme.primary.withAlpha(80)
                        : Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      profilePictures[index].toString(),
                      scale: 14,
                    ),
                  ),
                ),
              ),
              // Text(
              //   labels[index],
              //   style: const TextStyle(fontWeight: FontWeight.w500),
              // ),
              if (selectedIndex == index)
                Text(
                  'Selected',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop(profilePictures[selectedIndex!]);
            }
          },
          child: Text('Select'),
        )
      ],
    );
  }
}
