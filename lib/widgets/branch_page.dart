import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import './branch_popupmenu.dart';
import './rename_branch_dialog.dart';
import './task_card.dart';
import './add_task_dialog.dart';
import './empty_branch.dart';
import './confirmation_dialog.dart';
import '../entities/note.dart';
import '../entities/subtask.dart';
import '../entities/task.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _title = 'Учеба';

  bool _isCompletedFilter = false;
  bool _isFavoriteFilter = false;

  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  final List<Subtask> _subtasks = [];
  final List<Note> _notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _filteredTasks.isEmpty ? const EmptyBranch() : _createListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    final enteredText = await showDialog<String>(
      context: context,
      builder: (_) => const TaskCreationDialog(),
    );

    if (enteredText != null) {
      if (mounted) {
        final id = const Uuid().v4();
        _tasks.add(
          Task(
            title: enteredText,
            id: id,
            dateOfCreation: DateTime.now(),
          ),
        );
        _notes.add(Note.create(taskId: id));
        _filter();
      }
    }
  }

  Future<void> _showEditBranchDialog() async {
    final enteredText = await showDialog<String>(
      context: context,
      builder: (_) => RenameBranchDialog(branchTitle: _title),
    );

    if (enteredText != null) {
      if (mounted) {
        setState(() {
          _title = enteredText;
        });
      }
    }
  }

  Future<void> _showSubtasksDeleteDialog() {
    return showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        onOk: _deleteCompletedTasks,
        title: 'Подтвердите удаление',
        description: 'Удалить выполненные задачи? Это действие необратимо.',
      ),
    );
  }

  Future<void> _showCompleteTaskDialog({required String taskId}) {
    return showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        onOk: () => _toggleCompletion(taskId: taskId),
        title: 'Все шаги выполнены',
        description: 'Хотите завершить задание?',
      ),
    );
  }

  void _toggleCompletion({required String taskId}) {
    final index = _tasks.indexWhere((element) => element.id == taskId);
    _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);

    _filter();
  }

  void _toggleFavourite({required String taskId}) {
    final index = _tasks.indexWhere((element) => element.id == taskId);
    _tasks[index] = _tasks[index].copyWith(isFavourite: !_tasks[index].isFavourite);

    _filter();
  }

  void _deleteTask({required String taskId}) {
    final taskIndex = _tasks.indexWhere((element) => element.id == taskId);
    _notes.removeWhere((note) => note.taskId == _tasks[taskIndex].id);
    _subtasks.removeWhere((subtask) => subtask.taskId == _tasks[taskIndex].id);
    _tasks.removeAt(taskIndex);
    _filter();
  }

  void _updateTask(Task newTask) {
    final index = _tasks.indexWhere((element) => element.id == newTask.id);
    _tasks[index] = newTask;
    _filter();
  }

  void _deleteCompletedTasks() {
    final tasksForDelete = List<Task>.of(_tasks);
    for (var task in tasksForDelete) {
      _deleteTask(taskId: task.id);
    }
  }

  void _onFavoriteFilter() {
    _isFavoriteFilter = !_isFavoriteFilter;
    _filter();
  }

  void _onCompletedFilter() {
    _isCompletedFilter = !_isCompletedFilter;
    _filter();
  }

  void _filter() {
    Iterable<Task> showTasksIterable = _tasks;
    if (_isCompletedFilter) {
      showTasksIterable = showTasksIterable.where((task) => !task.isCompleted);
    }
    if (_isFavoriteFilter) {
      showTasksIterable = showTasksIterable.where((task) => task.isFavourite);
    }
    setState(() {
      _filteredTasks = showTasksIterable.toList();
    });
  }

  void _deleteSubtask(String subtaskId) {
    final subtaskIndex = _subtasks.indexWhere((subtask) => subtask.id == subtaskId);
    final taskIndex = _tasks.indexWhere((task) => task.id == _subtasks[subtaskIndex].taskId);

    _tasks[taskIndex] = _tasks[taskIndex].copyWith(
      subtaskCount: _tasks[taskIndex].subtaskCount - 1,
      completedSubtaskCount: _tasks[taskIndex].completedSubtaskCount + (_subtasks[subtaskIndex].isCompleted ? -1 : 0),
    );

    _subtasks.removeAt(subtaskIndex);
    _filter();
  }

  void _onSubtaskComplete(String subtaskId) async {
    final subtaskIndex = _subtasks.indexWhere((subtask) => subtask.id == subtaskId);
    final taskIndex = _tasks.indexWhere((task) => task.id == _subtasks[subtaskIndex].taskId);

    _subtasks[subtaskIndex] = _subtasks[subtaskIndex].copyWith(isCompleted: !_subtasks[subtaskIndex].isCompleted);

    Task updatedTask = _tasks[taskIndex].copyWith(
        completedSubtaskCount:
            _tasks[taskIndex].completedSubtaskCount + (_subtasks[subtaskIndex].isCompleted ? 1 : -1));

    if (updatedTask.subtaskCount == updatedTask.completedSubtaskCount && !updatedTask.isCompleted) {
      await _showCompleteTaskDialog(taskId: updatedTask.id);

      if (updatedTask.isCompleted != _tasks[taskIndex].isCompleted) {
        updatedTask = updatedTask.copyWith(isCompleted: true);
      }
    }

    setState(() {
      _tasks[taskIndex] = updatedTask;
    });

    _filter();
  }

  void _addSubtask(Subtask newSubtask) {
    final index = _tasks.indexWhere((task) => task.id == newSubtask.taskId);
    _subtasks.add(newSubtask);
    _tasks[index] = _tasks[index].copyWith(subtaskCount: _tasks[index].subtaskCount + 1);

    _filter();
  }

  void _onNoteChange(String? noteId, String text) {
    final noteIndex = _notes.indexWhere((note) => note.id == noteId);
    _notes[noteIndex] = _notes[noteIndex].copyWith(text: text);

    _filter();
  }

  void _onSubtaskTextChange(String? subtaskId, String text) {
    final subtaskIndex = _subtasks.indexWhere((subtask) => subtask.id == subtaskId);
    _subtasks[subtaskIndex] = _subtasks[subtaskIndex].copyWith(text: text);

    _filter();
  }

  Widget _createListView() => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: _filteredTasks.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) => TaskCard(
          task: _filteredTasks[index],
          subtasks: _subtasks,
          notes: _notes,
          onDismissSwap: (_) => _deleteTask(taskId: _filteredTasks[index].id),
          onTaskComplete: (_) => _toggleCompletion(taskId: _filteredTasks[index].id),
          onFavouriteTap: () => _toggleFavourite(taskId: _filteredTasks[index].id),
          updateCard: _updateTask,
          deleteCard: () => _deleteTask(taskId: _filteredTasks[index].id),
          onSubtaskDelete: _deleteSubtask,
          onSubtaskComplete: _onSubtaskComplete,
          addSubtask: _addSubtask,
          onNoteChange: _onNoteChange,
          onSubtaskTextChange: _onSubtaskTextChange,
        ),
        separatorBuilder: (_, __) => const Divider(),
      );

  AppBar _createAppBar() => AppBar(
        title: Text(_title),
        actions: <Widget>[
          BranchPopUpMenu(
            isShowCompleted: _isCompletedFilter,
            isShowFavorite: _isFavoriteFilter,
            onCompleted: _onCompletedFilter,
            onFavorite: _onFavoriteFilter,
            onDelete: _showSubtasksDeleteDialog,
            onEdit: _showEditBranchDialog,
          )
        ],
      );
}
