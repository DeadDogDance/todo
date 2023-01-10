import 'package:flutter/material.dart';

import './confirmation_dialog.dart';
import './task_popupmenu.dart';
import './task_edit_dialog.dart';
import '../entities/note.dart';
import '../entities/task.dart';
import '../entities/subtask.dart';
import '../widgets/subtask_card.dart';

class TaskScreen extends StatefulWidget {
  final Task task;
  final Function(Task) updateTask;
  final Function deleteTask;
  final Function(bool?) onTaskComplete;

  final List<Subtask> subtasks;
  final Function(String) onSubtaskComplete;
  final Function(String) onSubtaskDelete;
  final Function(Subtask) addSubtask;
  final Function(String?, String) onSubtaskTextChange;

  final Note note;
  final Function(String?, String) onNoteChange;

  const TaskScreen({
    Key? key,
    required this.task,
    required this.updateTask,
    required this.deleteTask,
    required this.onTaskComplete,
    required this.subtasks,
    required this.onSubtaskComplete,
    required this.onSubtaskDelete,
    required this.onSubtaskTextChange,
    required this.addSubtask,
    required this.note,
    required this.onNoteChange,
  }) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Task _task;
  late String _date;
  late TextEditingController noteController;
  late List<Subtask> filteredSubtasks;

  final padding = const EdgeInsets.all(12);

  @override
  void initState() {
    _task = widget.task;
    _date = 'Создано: ${_task.dateOfCreation.day}.${_task.dateOfCreation.month}.${_task.dateOfCreation.year}' +
        ' ${_task.dateOfCreation.hour}:${_task.dateOfCreation.minute}';

    filteredSubtasks = List<Subtask>.of(widget.subtasks);
    filteredSubtasks.retainWhere((subtask) => subtask.taskId == _task.id);
    noteController = TextEditingController(text: widget.note.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffb5c9fd),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 160,
            backgroundColor: const Color(0xff6202ee),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 50, right: 40, top: 20),
              title: Text(_task.title),
            ),
            actions: [
              TaskPopUpMenu(
                onEdit: _editTaskDialog,
                onStepsDelete: _deleteCompletedStepsDialog,
                onTaskDelete: _deleteTaskDialog,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 25,
              left: 16,
              right: 16,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return _dateOfCreation();
                  } else if (index == filteredSubtasks.length + 1) {
                    return _addStepWidget(noteController: noteController);
                  } else {
                    return SubtaskCard(
                      subtask: filteredSubtasks[index - 1],
                      onCompleted: (_) => _onSubtaskComplete(index - 1),
                      deleteSubtask: () => _onSubtaskDelete(subtaskId: filteredSubtasks[index].id),
                      onSubtaskTextChange: _onSubtaskTextChange,
                    );
                  }
                },
                childCount: filteredSubtasks.length + 2,
              ),
            ),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: _datesCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: _photos(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(_task.isCompleted ? Icons.close : Icons.check),
        onPressed: () {
          widget.onTaskComplete(true); //Костыль
          setState(() {
            _task = _task.copyWith(isCompleted: !_task.isCompleted);
          });
        },
      ),
    );
  }

  Future<void> _editTaskDialog() async {
    final editedTask = await showDialog(
      context: context,
      builder: (_) => TaskEditDialog(
        task: _task,
      ),
    );
    if (editedTask != null) {
      if (mounted) {
        widget.updateTask(editedTask);
        setState(() {
          _task = editedTask;
        });
      }
    }
  }

  Future<void> _deleteTaskDialog() {
    return showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Удалить задачу?',
        description: 'Это действие нельзя отменить.',
        onOk: _deleteTask,
      ),
    );
  }

  Future<void> _deleteCompletedStepsDialog() {
    return showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: 'Подтвердите удаление',
        description: 'Удалить выполненные шаги?.Это действие необратимо.',
        onOk: () {
          final completedSubtasks = List<Subtask>.of(filteredSubtasks);
          completedSubtasks.retainWhere((subtask) => subtask.isCompleted);
          for (var i = 0; i < completedSubtasks.length; i++) {
            _onSubtaskDelete(subtaskId: completedSubtasks[i].id);
          }
        },
      ),
    );
  }

  void _deleteTask() {
    Navigator.of(context).pop();
    widget.deleteTask();
  }

  void _onSubtaskComplete(int index) {
    widget.onSubtaskComplete(filteredSubtasks[index].id);
    Task updatedTask = _task.copyWith(
        completedSubtaskCount: _task.completedSubtaskCount + (filteredSubtasks[index].isCompleted ? 1 : -1));
    setState(() {
      filteredSubtasks[index] = filteredSubtasks[index].copyWith(isCompleted: !filteredSubtasks[index].isCompleted);
      _task = updatedTask;
    });
  }

  void _onSubtaskTextChange(String subtaskId, String text) {
    widget.onSubtaskTextChange(subtaskId, text);
    final subtaskIndex = filteredSubtasks.indexWhere((subtask) => subtask.id == subtaskId);
    filteredSubtasks[subtaskIndex] = filteredSubtasks[subtaskIndex].copyWith(text: text);
  }

  void _onSubtaskDelete({required String subtaskId}) {
    widget.onSubtaskDelete(subtaskId);
    Task updatedTask = _task.copyWith(subtaskCount: _task.subtaskCount - 1);
    setState(() {
      filteredSubtasks.removeWhere((subtask) => subtask.id == subtaskId);
      _task = updatedTask;
    });
  }

  Container _addStepWidget({required TextEditingController noteController}) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Subtask newSubtask = Subtask.create(taskId: _task.id);
                    widget.addSubtask(newSubtask);
                    setState(() {
                      filteredSubtasks.add(newSubtask);
                      _task = _task.copyWith(subtaskCount: _task.subtaskCount + 1);
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить шаг'),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Divider(
                color: Colors.grey,
                thickness: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: TextField(
                controller: noteController,
                maxLines: null,
                onChanged: (text) {
                  widget.onNoteChange(widget.note.id, text);
                },
                decoration: const InputDecoration(
                  hintText: 'Заметки по задаче...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      );

  Card _datesCard() => Card(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('notify'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.black,
                ),
                label: const Text('Напомнить'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0),
              child: Divider(
                thickness: 2,
                color: Colors.grey,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('add date'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.today,
                  color: Colors.black,
                ),
                label: const Text('Добавить дату выполнения'),
              ),
            )
          ],
        ),
      );

  Container _dateOfCreation() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(3),
            topLeft: Radius.circular(3),
          ),
        ),
        padding: padding,
        child: Text(
          _date,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      );

  Container _photos() => Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                color: Colors.teal,
              ),
              height: 100,
              child: IconButton(
                icon: const Icon(
                  Icons.attachment,
                  color: Colors.white,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('add photo'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
}
