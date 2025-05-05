import 'package:bloom/models/note_layout.dart';
import 'package:flutter/material.dart';

class EntriesBackgroundImages extends StatefulWidget {
  final BackgroundImageNotifier backgroundImageNotifier;
  const EntriesBackgroundImages(
      {super.key, required this.backgroundImageNotifier});

  @override
  State<EntriesBackgroundImages> createState() =>
      _EntriesBackgroundImagesState();
}

class _EntriesBackgroundImagesState extends State<EntriesBackgroundImages> {
  List<String> backgroundImageUrlsList = [
    'assets/background_images/obsidian_essence.jpg',
    'assets/background_images/foggy_peak_1.jpg',
    'assets/background_images/foggy_peak_2.jpg',
    'assets/background_images/mountain_peak_dark.jpg',
    'assets/background_images/roman_pillars.jpg',
    'assets/background_images/sand_dunes.jpg',
    'assets/background_images/sunset_in_the_mountains.jpg',
    'assets/background_images/white_globe.jpg',
    'assets/background_images/cozy_autumn_rain.gif',
  ];
  List<String> backgroundImageUrlsNamesList = [
    'Obsidian Essence',
    'Foggy Peak 1',
    'Foggy Peak 2',
    'Mountain Peak - Dark',
    'Roman Pillars',
    'Sand Dunes',
    'Sunset in the Mountains',
    'White Globe',
    'Cozy Autumn Rain',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              widget.backgroundImageNotifier.backgroundImageUrl = '';
              Navigator.pop(context);
            },
            icon: Text(
              'Remove',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic pre-installed backgrounds title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                'Pre-installed',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            // Basic pre-installed backgrounds gridview
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.5),
                  itemCount: backgroundImageUrlsList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        widget.backgroundImageNotifier.backgroundImageUrl =
                            backgroundImageUrlsList[index];
                        Navigator.pop(context);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          backgroundImageUrlsList[index],
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  }),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            // Advanced specific topic backgrounds title
          ],
        ),
      ),
    );
  }
}
