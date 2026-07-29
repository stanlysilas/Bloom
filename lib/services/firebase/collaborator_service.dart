import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollaboratorService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> addCollaborator({
    required String noteId,
    required String collaboratorEmail,
    required String permission,
  }) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: collaboratorEmail.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return "User not found!";
      }

      final collaboratorUid = querySnapshot.docs.first.id;

      String field;
      switch (permission) {
        case 'owner':
          field = 'collaborators.owners';
          break;
        case 'edit':
          field = 'collaborators.editors';
          break;
        default:
          field = 'collaborators.viewers';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('entries')
          .doc(noteId)
          .update({
        field: FieldValue.arrayUnion([collaboratorUid])
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Future<Map<String, String>?> showAddCollaboratorDialog() {
  //   final TextEditingController emailController = TextEditingController();
  //   String permission = 'view';

  //   return showDialog<Map<String, String>?>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) {
  //       return AlertDialog(
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Title
  //                 Text(
  //                   'Add Collaborator',
  //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // Email field
  //                 TextField(
  //                   controller: emailController,
  //                   keyboardType: TextInputType.emailAddress,
  //                   decoration: InputDecoration(
  //                     hintText: 'Email address',
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     contentPadding: const EdgeInsets.symmetric(
  //                       horizontal: 14,
  //                       vertical: 12,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 12),

  //                 // Permission dropdown
  //                 DropdownButtonFormField<String>(
  //                   initialValue: permission,
  //                   decoration: InputDecoration(
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     contentPadding: const EdgeInsets.symmetric(
  //                       horizontal: 14,
  //                       vertical: 10,
  //                     ),
  //                   ),
  //                   items: const [
  //                     DropdownMenuItem(
  //                       value: 'view',
  //                       child: Text('View only'),
  //                     ),
  //                     DropdownMenuItem(
  //                       value: 'edit',
  //                       child: Text('View & edit'),
  //                     ),
  //                   ],
  //                   onChanged: (value) {
  //                     if (value == null) return;
  //                     setState(() {
  //                       permission = value;
  //                     });
  //                   },
  //                 ),
  //                 const SizedBox(height: 20),

  //                 // Buttons row
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.of(context).pop(null),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     FilledButton(
  //                       onPressed: () {
  //                         final email = emailController.text.trim();
  //                         if (email.isEmpty) return;
  //                         Navigator.of(context).pop({
  //                           'email': email,
  //                           'permission': permission,
  //                         });
  //                       },
  //                       child: const Text('Add'),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
}
