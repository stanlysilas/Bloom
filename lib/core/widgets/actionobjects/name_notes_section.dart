import 'package:bloom/core/widgets/bloom_textfield.dart';
import 'package:flutter/material.dart';

class NameNotesSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController notesController;

  const NameNotesSection({
    super.key,
    required this.nameController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Name'),
        ),
        const SizedBox(height: 5),
        BloomTextfield(
          controller: nameController,
          hintText: 'Buy groceries',
          minLines: 1,
          maxLines: 3,
          obscureText: false,
          textInputType: TextInputType.text,
          autoFocus: true,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Notes'),
        ),
        const SizedBox(height: 5),
        BloomTextfield(
          controller: notesController,
          hintText: 'Milk, vegetables...',
          minLines: 1,
          maxLines: 5,
          obscureText: false,
          textInputType: TextInputType.text,
          autoFocus: true,
          focusNode: FocusNode(),
        ),
      ],
    );
  }
}
