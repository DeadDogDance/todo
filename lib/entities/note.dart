import 'package:uuid/uuid.dart';

class Note {
  final String? id;
  final String? taskId;
  final String? text;

  Note({
    required this.id,
    required this.taskId,
    this.text = '',
  });

  factory Note.create({
    required taskId,
    String? id,
    String? text,
  }) =>
      Note(
        id: id ?? const Uuid().v4(),
        text: text ?? '',
        taskId: taskId,
      );

  Note copyWith({
    String? id,
    String? taskId,
    String? text,
  }) =>
      Note(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        text: text ?? this.text,
      );
}
