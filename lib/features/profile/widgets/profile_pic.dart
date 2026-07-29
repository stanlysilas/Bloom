import 'package:flutter/material.dart';

class ProfilePictureDialog extends StatefulWidget {
  const ProfilePictureDialog({super.key});

  @override
  State<ProfilePictureDialog> createState() => _ProfilePictureDialogState();
}

class _ProfilePictureDialogState extends State<ProfilePictureDialog> {
  int? selectedIndex;

  final List<String> profilePictures = [
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
    return AlertDialog(
      title: const Text(
        'Choose a profile picture',
        style: TextStyle(fontFamily: 'ClashGrotesk'),
      ),
      content: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width / 2,
        child: GridView.builder(
          itemCount: profilePictures.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 130,
          ),
          itemBuilder: (context, index) {
            final picture = profilePictures[index];

            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: selectedIndex == index
                          ? Theme.of(context).colorScheme.primary.withAlpha(80)
                          : Colors.transparent,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        picture,
                        scale: 14,
                      ),
                    ),
                  ),
                ),
                if (selectedIndex == index)
                  const Text(
                    'Selected',
                    style: TextStyle(color: Colors.grey),
                  )
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: selectedIndex == null
              ? null
              : () {
                  Navigator.pop(
                    context,
                    profilePictures[selectedIndex!],
                  );
                },
          child: const Text('Select'),
        )
      ],
    );
  }
}
