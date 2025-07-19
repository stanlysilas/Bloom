// More types of objects from database
import 'package:bloom/components/custom_templates_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomTemplatesScreen extends StatefulWidget {
  const CustomTemplatesScreen({super.key});

  @override
  State<CustomTemplatesScreen> createState() => _CustomTemplatesScreenState();
}

class _CustomTemplatesScreenState extends State<CustomTemplatesScreen> {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  bool isSearchEnabled = false;

  // InitState method
  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (isSearchEnabled) {
        setState(() {});
      }
    });
  }

  // Method to fetch the custom templates from firebase
  Stream fetchTemplates() {
    if (isSearchEnabled == false) {
      return FirebaseFirestore.instance.collection('templates').snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('templates')
          .where('templateTitle', isGreaterThanOrEqualTo: searchController.text)
          .where('templateTitle',
              isLessThanOrEqualTo: "${searchController.text}\uf8ff")
          .snapshots();
    }
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(fetchTemplates);
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
              });
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
        bottom: isSearchEnabled
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 70),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: SearchBar(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).primaryColorLight),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTapOutside: (event) {
                      searchFocusNode.unfocus();
                    },
                    leading: const Icon(Icons.search_rounded),
                    trailing: [
                      if (searchController.text.isNotEmpty)
                        IconButton(
                            onPressed: () {
                              searchFocusNode.unfocus();
                              setState(() {
                                isSearchEnabled = false;
                              });
                            },
                            icon: const Icon(Icons.close_rounded))
                    ],
                    hintText: 'Search for templates',
                    elevation: const WidgetStatePropertyAll(0),
                  ),
                ))
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isSearchEnabled)
              SizedBox(
                height: 24,
              ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                stream: fetchTemplates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Skeletonizer(
                      enabled: true,
                      containersColor: Theme.of(context).primaryColorLight,
                      child: Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context)
                              .primaryColorLight
                              .withAlpha(100),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 130,
                              width: double.maxFinite,
                            ),
                            Text('This is the title of the template here...'),
                            Text(
                                'This is the description or the details of the template here...'),
                            Text('The created date and author...'),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: const Duration(milliseconds: 500));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No matching templates were found'),
                    );
                  }
                  final templateList = snapshot.data!.docs;
                  return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: templateList.length,
                      itemBuilder: (context, index) {
                        final templates = templateList[index];
                        final String templateId = templates['templateId'];
                        final String templateThumbnail =
                            templates['templateThumbnail'];
                        final String templateIcon = templates['templateIcon'];
                        final String templateTitle = templates['templateTitle'];
                        final String templateDescription =
                            templates['templateDescription'];
                        final List templateChildren =
                            templates['templateChildren'];
                        final String templateType = templates['templateType'];
                        final Timestamp timestamp = templates['dateOfCreation'];
                        final String createdBy = templates['createdBy'];
                        final DateTime dateOfCreation = timestamp.toDate();
                        return CustomTemplatesCard(
                          templateId: templateId,
                          templateType: templateType,
                          templateThumbnail: templateThumbnail,
                          templateIcon: templateIcon,
                          templateTitle: templateTitle,
                          templateDescription: templateDescription,
                          templateChildren: templateChildren,
                          dateOfCreation: dateOfCreation,
                          createdBy: createdBy,
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
