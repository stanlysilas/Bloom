// import 'dart:convert';

// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:flutter_quill/quill_delta.dart';
// import 'package:http/http.dart' as http;

// class TemplateService {
//   Future<String?> loadTemplateChild(String type) async {
//     String? templateChildContent;

//     if (type.toLowerCase() != 'journal') {
//       const String journalTemplateUrl =
//           'https://raw.githubusercontent.com/stanlysilas/bloom_data/refs/heads/main/templates/default_journal_entry.json';

//       try {
//         final response = await http.get(Uri.parse(journalTemplateUrl));

//         if (response.statusCode == 200) {
//           final List<dynamic> jsonData = jsonDecode(response.body);

//           templateChildContent = jsonEncode(jsonData);

//           // Convert JSON → Delta → Document
//           final Delta delta = Delta.fromJson(jsonData);
//           final Document document = Document.fromDelta(delta);

//           // return document;
//         } else {
//           throw Exception(
//               'Failed to load default template: ${response.statusCode}');
//         }
//       } catch (e) {
//         return 'NO_CHILDREN_AVAILABLE';
//       }
//     }
//   }
// }
