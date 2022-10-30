import 'package:flutter/material.dart';
import '../entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(DismissDirection) onDismissSwap;
  final Function(bool?) onCheckboxTap;
  final VoidCallback onFavouriteTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onDismissSwap,
    required this.onCheckboxTap,
    required this.onFavouriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const cardMargin = EdgeInsets.symmetric(vertical: 4.0);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: cardMargin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Colors.red,
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      onDismissed: onDismissSwap,
      child: Card(
        margin: cardMargin,
        child: Row(
          children: [
            Checkbox(
              hoverColor: Colors.grey,
              value: task.isCompleted,
              shape: const CircleBorder(),
              onChanged: onCheckboxTap,
            ),
            Text(task.title),
            const Spacer(),
            IconButton(
              icon: Icon(task.isFavourite ? Icons.star : Icons.star_border),
              onPressed: onFavouriteTap,
            ),
          ],
        ),
      ),
    );
  }
}
