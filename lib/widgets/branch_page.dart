import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../entities/task.dart';
import './branch_popupmenu.dart';
import './rename_branch.dart';
import './task_card.dart';
import './add_task_dialog.dart';
import './empty_branch.dart';
import './confirmation_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffb5c9fd),
      appBar: _createAppBar(),
      body: _filteredTasks.isEmpty ? const EmptyBranch() : _createListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add task',
        backgroundColor: Colors.teal,
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
        _tasks.add(
          Task(
            title: enteredText,
            id: const Uuid().v4(),
          ),
        );
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

  Future<void> _showDeleteDialog() {
    return showDialog<String>(
      context: context,
      builder: (_) => ConfirmationDialog(
        onOk: _deleteCompletedTasks,
        title: 'Подтвердите удаление',
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
    _tasks.removeWhere((element) => element.id == taskId);
    _filter();
  }

  void _deleteCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    _filter();
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

  Widget _createListView() => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: _filteredTasks.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) => TaskCard(
          task: _filteredTasks[index],
          onDismissSwap: (_) => _deleteTask(taskId: _filteredTasks[index].id),
          onCheckboxTap: (_) => _toggleCompletion(taskId: _filteredTasks[index].id),
          onFavouriteTap: () => _toggleFavourite(taskId: _filteredTasks[index].id),
        ),
        separatorBuilder: (_, __) => const Divider(),
      );

  AppBar _createAppBar() => AppBar(
        backgroundColor: const Color(0xff6202ee),
        title: Text(_title),
        actions: <Widget>[
          AppBarPopUpMenu(
            isShowCompleted: _isCompletedFilter,
            isShowFavorite: _isFavoriteFilter,
            onCompleted: _onCompletedFilter,
            onFavorite: _onFavoriteFilter,
            onDelete: _showDeleteDialog,
            onEdit: _showEditBranchDialog,
          )
        ],
      );
}
