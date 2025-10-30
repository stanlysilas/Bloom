// This is the BloomAI inside the note_layout.dart model for an entry
import 'package:bloom/components/textfield_nobackground.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

// The actual method for showing the modalBottomSheet with the textField for the BloomAI
void showBloomAI(BuildContext context) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BloomAI();
      });
}

// The layout statefulwidget for the BloomAI
class BloomAI extends StatefulWidget {
  const BloomAI({super.key});

  @override
  State<BloomAI> createState() => _BloomAIState();
}

class _BloomAIState extends State<BloomAI> {
  // Required variables
  final bloomAITextController = TextEditingController();
  final bloomAIFocusNode = FocusNode();
  final model =
      FirebaseAI.vertexAI().generativeModel(model: 'gemini-2.0-flash');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: MyTextfieldNobackground(
                autoFocus: true,
                controller: bloomAITextController,
                hintText: 'Ask Bloom AI...',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
                focusNode: bloomAIFocusNode,
                readOnly: false,
                suffixIcon: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(100)),
                  child: IconButton(
                    onPressed: () async {
                      // Functionality to submit the query of the user
                      // print("User's query: ${bloomAITextController.text}");
                      // final prompt = [
                      //   Content.text(bloomAITextController.text)
                      // ];
                      // // final response = await model.generateContent(prompt, generationConfig: GenerationConfig());
                      // // print(response.text);
                      // bloomAITextController.clear();
                    },
                    icon: Icon(Icons.send_rounded),
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
