import 'dart:convert';

import 'package:bloom/models/background_model.dart';
import 'package:bloom/models/note_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EntriesBackgroundImages extends StatefulWidget {
  final BackgroundImageNotifier backgroundImageNotifier;
  final String from;
  const EntriesBackgroundImages(
      {super.key, required this.backgroundImageNotifier, required this.from});

  @override
  State<EntriesBackgroundImages> createState() =>
      _EntriesBackgroundImagesState();
}

class _EntriesBackgroundImagesState extends State<EntriesBackgroundImages> {
  @override
  void initState() {
    super.initState();
    fetchBackgrounds();
  }

  /// Fetch backgrounds from GitHub repo.
  Future<Map<String, List<BackgroundModel>>> fetchBackgrounds() async {
    final url = Uri.parse(
      'https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/backgrounds/backgrounds.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.map((category, items) {
          final list =
              (items as List).map((e) => BackgroundModel.fromJson(e)).toList();
          return MapEntry(category, list);
        });
      } else {
        throw Exception('Failed to load backgrounds: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching backgrounds: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainer)),
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.grey)),
        title: Text('Select Background',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            tooltip: 'Remove background',
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.errorContainer)),
            onPressed: () {
              widget.backgroundImageNotifier.backgroundImageUrl = '';
              if (widget.from == 'more') {
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic pre-installed backgrounds title
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 24.0),
            //   child: Text(
            //     'Pre-installed',
            //     style: TextStyle(color: Theme.of(context).colorScheme.primary),
            //   ),
            // ),
            // // Basic pre-installed backgrounds gridview
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
            //   child: GridView.builder(
            //       physics: const NeverScrollableScrollPhysics(),
            //       shrinkWrap: true,
            //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //           crossAxisCount: 3,
            //           crossAxisSpacing: 8,
            //           mainAxisSpacing: 8,
            //           childAspectRatio: 1.5),
            //       itemCount: backgroundImageUrlsList.length,
            //       itemBuilder: (context, index) {
            //         return InkWell(
            //           borderRadius: BorderRadius.circular(16),
            //           onTap: () {
            //             widget.backgroundImageNotifier.backgroundImageUrl =
            //                 backgroundImageUrlsList[index];
            //             if (widget.from == 'more') {
            //               Navigator.pop(context);
            //               Navigator.pop(context);
            //             } else {
            //               Navigator.pop(context);
            //             }
            //           },
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(16),
            //             child: Image.asset(
            //               backgroundImageUrlsList[index],
            //               filterQuality: FilterQuality.low,
            //               fit: BoxFit.fill,
            //             ),
            //           ),
            //         );
            //       }),
            // ),
            // Divider(),
            // Backgrounds sorted category wise
            FutureBuilder<Map<String, List<BackgroundModel>>>(
              future: fetchBackgrounds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    year2023: false,
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Failed to load backgrounds"));
                }

                final data = snapshot.data ?? {};
                if (data.isEmpty) {
                  return const Center(child: Text("No backgrounds available"));
                }

                // Build a section for each category
                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  children: data.entries.map((entry) {
                    final category = entry.key;
                    final images = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            category,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.5),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final bg = images[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // Put the network url as the url for background in provider
                                  widget.backgroundImageNotifier
                                      .backgroundImageUrl = bg.url;
                                  if (widget.from == 'more') {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                      filterQuality: FilterQuality.low,
                                      imageUrl: bg.url,
                                      fit: BoxFit.fill,
                                      errorWidget: (_, __, ___) => Icon(
                                          Icons.error,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
