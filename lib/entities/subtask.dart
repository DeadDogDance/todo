import 'package:uuid/uuid.dart';

class Subtask {
  final String id;
  final String taskId;
  final bool isCompleted;
  final String text;

  Subtask({
    required this.id,
    required this.taskId,
    this.text = '',
    this.isCompleted = false,
  });

  factory Subtask.create({
    required String taskId,
    String? id,
    bool? isCompleted,
    String? text,
  }) =>
      Subtask(
        id: id ?? const Uuid().v4(),
        taskId: taskId,
        isCompleted: isCompleted ?? false,
        text: text ?? '',
      );

  Subtask copyWith({
    String? id,
    String? taskId,
    bool? isCompleted,
    String? text,
  }) =>
      Subtask(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        isCompleted: isCompleted ?? this.isCompleted,
        text: text ?? this.text,
      );
}
