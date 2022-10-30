class Task {
  final String id;
  final bool isCompleted;
  final String title;
  final bool isFavourite;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isFavourite = false,
  });

  Task copyWith({
    String? id,
    bool? isCompleted,
    String? title,
    bool? isFavourite,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
        isFavourite: isFavourite ?? this.isFavourite,
      );
}
