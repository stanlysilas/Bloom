import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BookPagesLoadingState extends StatelessWidget {
  const BookPagesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Skeletonizer(
        enabled: true,
        containersColor: Theme.of(context).primaryColorLight,
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
      ),
    );
  }
}
