import 'package:flutter/material.dart';

class BookPagesEmptyState extends StatelessWidget {
  const BookPagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            height: 260,
            width: 260,
            image: AssetImage('assets/images/entriesEmptyBackground.png'),
          ),
          Text(
            'No pages yet',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'Click on the + icon to make a new page',
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
