import 'package:flutter/material.dart';

class SignupGreeting extends StatelessWidget {
  const SignupGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Signup ',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const Text(
            'to start ',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Blooming!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ],
      ),
    );
  }
}
