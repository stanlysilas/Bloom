import 'package:flutter/material.dart';

class LoginGreeting extends StatelessWidget {
  const LoginGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 95,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Image.asset(
                  'assets/icons/default_app_icon_png.png',
                  scale: 20,
                ),
                Text(
                  'Bloom',
                  style: TextStyle(fontFamily: 'ClashGrotesk', fontSize: 16),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  ' did you miss the way you ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Bloomed?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
