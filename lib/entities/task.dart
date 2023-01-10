class Task {
  final String id;
  final bool isCompleted;
  final String title;
  final bool isFavourite;
  final DateTime dateOfCreation;
  final int subtaskCount;
  final int completedSubtaskCount;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isFavourite = false,
    this.subtaskCount = 0,
    this.completedSubtaskCount = 0,
    required this.dateOfCreation,
  });

  Task copyWith({
    String? id,
    bool? isCompleted,
    String? title,
    bool? isFavourite,
    DateTime? dateOfCreation,
    int? subtaskCount,
    int? completedSubtaskCount,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        isFavourite: isFavourite ?? this.isFavourite,
        dateOfCreation: dateOfCreation ?? this.dateOfCreation,
        subtaskCount: subtaskCount ?? this.subtaskCount,
        completedSubtaskCount: completedSubtaskCount ?? this.completedSubtaskCount,
      );
}
