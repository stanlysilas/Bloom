import 'dart:convert';

import 'package:bloom/core/responsive/dimensions.dart';
import 'package:bloom/models/background_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EntriesBackgroundImages extends StatefulWidget {
  final String backgroundImageUrl;
  const EntriesBackgroundImages({super.key, required this.backgroundImageUrl});

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
              Navigator.pop(context, '');
            },
            icon: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.onErrorContainer),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width > mobileWidth ? 650 : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      return const Center(
                          child: Text("No backgrounds available"));
                    }

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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                category,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14.0),
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
                                    onTap: () async {
                                      Navigator.pop(context, bg.url);
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
        ),
      ),
    );
  }
}
