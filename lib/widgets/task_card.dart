import 'package:flutter/material.dart';
import './task_page.dart';
import '../entities/note.dart';
import '../entities/task.dart';
import '../entities/subtask.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function deleteCard;
  final Function(Task) updateCard;
  final Function(bool?) onTaskComplete;
  final Function(DismissDirection) onDismissSwap;
  final VoidCallback onFavouriteTap;

  final List<Subtask> subtasks;
  final Function(String) onSubtaskDelete;
  final Function(String) onSubtaskComplete;
  final Function(Subtask) addSubtask;
  final Function(String?, String) onSubtaskTextChange;

  final List<Note> notes;
  final Function(String?, String) onNoteChange;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onDismissSwap,
    required this.onFavouriteTap,
    required this.onTaskComplete,
    required this.updateCard,
    required this.deleteCard,
    required this.subtasks,
    required this.onSubtaskDelete,
    required this.onSubtaskComplete,
    required this.onSubtaskTextChange,
    required this.addSubtask,
    required this.notes,
    required this.onNoteChange,
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
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskScreen(
                  task: task,
                  subtasks: subtasks,
                  updateTask: updateCard,
                  deleteTask: deleteCard,
                  onTaskComplete: onTaskComplete,
                  onSubtaskComplete: onSubtaskComplete,
                  onSubtaskDelete: onSubtaskDelete,
                  addSubtask: addSubtask,
                  onSubtaskTextChange: onSubtaskTextChange,
                  note: notes.firstWhere((note) => note.taskId == task.id),
                  onNoteChange: onNoteChange,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Checkbox(
                hoverColor: Colors.grey,
                value: task.isCompleted,
                shape: const CircleBorder(),
                onChanged: onTaskComplete,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(task.title),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${task.completedSubtaskCount} из ${task.subtaskCount}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                child: IconButton(
                  icon: Icon(
                    task.isFavourite ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: onFavouriteTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
