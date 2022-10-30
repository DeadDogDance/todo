import 'package:uuid/uuid.dart';

class Task {
  static const _uuid = Uuid();

  String id = _uuid.v4();
  final bool isCompleted;
  final String title;
  final bool isFavourite;

  Task({
    required this.title,
    this.isCompleted = false,
    this.isFavourite = false,
  });

  Task copyWith({
    String? id,
    bool? isCompleted,
    String? title,
    bool? isFavourite,
  }) {
    final task = Task(
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavourite: isFavourite ?? this.isFavourite,
    );
    task.id = id ?? this.id;
    return task;
  }
}
