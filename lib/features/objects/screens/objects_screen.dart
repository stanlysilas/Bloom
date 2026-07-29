import 'dart:core';

import 'package:bloom/features/objects/shared/widgets/objects_tile.dart';
import 'package:bloom/features/objects/shared/widgets/filter_strip.dart';
import 'package:bloom/models/bloom_object_model.dart';
import 'package:bloom/services/firebase/object_service.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final objectService = ObjectService();
  String sortValue = 'Recent';
  final objectFilters = [
    const FilterOption(
      value: 'Recent',
      title: 'Recent',
      subtitle: 'Sort from recent to oldest',
    ),
    const FilterOption(
      value: 'Oldest',
      title: 'Oldest',
      subtitle: 'Sort from oldest to recent',
    ),
    const FilterOption(
      value: 'Favorites',
      title: 'Favorites',
      subtitle: 'Show Favorite objects',
    ),
  ];
  late Stream<List<BloomObjectModel>> objectsStream;

  @override
  void initState() {
    super.initState();
    objectsStream = objectService.fetchObjects(sortValue);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objects',
            style: TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterStrip(
              onChanged: (value) => setState(() {
                sortValue = value;
                objectsStream = objectService.fetchObjects(sortValue);
              }),
              sortValue: sortValue,
              filters: objectFilters,
            ),
            StreamBuilder<List<BloomObjectModel>>(
                stream: objectsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        ...List.generate(3, growable: false, (index) {
                          return Skeletonizer(
                            enabled: true,
                            containersColor:
                                Theme.of(context).primaryColorLight,
                            child: ListTile(
                              leading: Icon(Icons.abc),
                              title: Text(
                                'So this is the text of the title of the object here...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                'So this is the text of the subtitle of the object here...',
                                maxLines: 1,
                              ),
                              trailing: Text('End'),
                            ),
                          );
                        }),
                      ],
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(left: 14.0, right: 14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              height: 200,
                              width: 200,
                              image: AssetImage(
                                  'assets/images/allCompletedBackground.png'),
                            ),
                            Text(
                              'Make a new entry',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Click on the + icon to make a new note, document your life and more',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child:
                          Text('Error occurred while getting your objects...'),
                    );
                  }
                  final objects = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: objects.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final object = objects[index];
                      return ObjectsTile(
                        innerPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        bloomObject: object,
                      );
                    },
                  );
                }),
            const SizedBox(
              height: 64,
            )
          ],
        ),
      ),
    );
  }
}
