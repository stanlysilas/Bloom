import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatesDialog extends StatefulWidget {
  final String updatesCollectionId;
  const UpdatesDialog({super.key, required this.updatesCollectionId});

  @override
  State<UpdatesDialog> createState() => _UpdatesDialogState();
}

class _UpdatesDialogState extends State<UpdatesDialog> {
  bool _isLoading = true;
  List<DocumentSnapshot> _unseenUpdates = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUpdateData();
  }

  Future<void> _loadUpdateData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenIds = prefs.getStringList('seenUpdateIds') ?? [];
      print(seenIds);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('appData')
          .doc('update_dialog')
          .collection(widget.updatesCollectionId)
          .orderBy('date', descending: false)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Filter out updates that have already been seen
        final filtered = querySnapshot.docs.where((doc) {
          final data = doc.data();
          final updateId = data['updateId'] as String?;
          return updateId != null && !seenIds.contains(updateId);
        }).toList();

        if (filtered.isEmpty) {
          if (mounted) Navigator.pop(context);
          return;
        }

        setState(() {
          _unseenUpdates = filtered;
          _isLoading = false;
        });
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error fetching updates: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _acknowledgeAndNext() async {
    final currentUpdate =
        _unseenUpdates[_currentIndex].data() as Map<String, dynamic>;
    final String? updateId = currentUpdate['updateId'];

    if (updateId != null) {
      final prefs = await SharedPreferences.getInstance();
      final seenIds = prefs.getStringList('seenUpdateIds') ?? [];

      if (!seenIds.contains(updateId)) {
        seenIds.add(updateId);
        await prefs.setStringList('seenUpdateIds', seenIds);
      }
    }

    if (_currentIndex < _unseenUpdates.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _unseenUpdates[_currentIndex].data() as Map<String, dynamic>;
    final title = data['title'] ?? 'New Update!';
    final description = data['description'] ?? 'Check out the latest changes.';
    final progressText =
        "Update ${_currentIndex + 1} of ${_unseenUpdates.length}";

    return AlertDialog(
      icon: const Icon(Icons.new_releases, size: 32),
      constraints: BoxConstraints(maxWidth: 450),
      title: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
                fontFamily: 'ClashGrotesk', fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(progressText, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
      content: Text(description),
      actions: [
        // if (_unseenUpdates.length > 1)
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: const Text('Close'),
        //   ),
        TextButton(
          onPressed: _acknowledgeAndNext,
          child: Text(
              _currentIndex < _unseenUpdates.length - 1 ? 'Next' : 'Got it'),
        ),
      ],
    );
  }
}
