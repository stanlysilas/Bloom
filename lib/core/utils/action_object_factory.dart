import 'package:bloom/models/action_object_model.dart';
import 'package:bloom/models/event_model.dart';
import 'package:bloom/models/habit_model.dart';
import 'package:bloom/models/task_model.dart';

class ActionObjectFactory {
  static ActionObjectModel fromFirestore(Map<String, dynamic> data) {
    String? type = data['actionObjectType'] ?? data['type'];

    type ??= _inferType(data);

    switch (type) {
      case 'task':
        return TaskModel.fromFirestore(data, []);
      case 'habit':
        return HabitModel.fromFirestore(data);
      case 'event':
        return EventModel.fromFirestore(data);
      default:
        throw Exception('Unknown action object type: $type');
    }
  }

  static String? _inferType(Map<String, dynamic> data) {
    if (data.containsKey('taskId')) return 'task';
    if (data.containsKey('habitId')) return 'habit';
    if (data.containsKey('eventId')) return 'event';
    return null;
  }
}
