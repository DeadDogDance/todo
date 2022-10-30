import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo/widgets/branch_popupmenu.dart';
import 'package:todo/widgets/rename_branch.dart';

import '../entities/task.dart';
import '../entities/assets.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

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
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
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
      ),
      body: Container(
        child: _filteredTasks.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(Assets.todoListBackground),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(Assets.todoList),
                    ),
                  ]),
                  const SizedBox(
                    child: Text(
                      "На данный\n момент задачи\n отсутствуют",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                itemCount: _filteredTasks.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) => TaskCard(
                  task: _filteredTasks[index],
                  key: ValueKey(_tasks[index].id),
                  onDismissSwap: (_) => _deleteTask(taskIndex: index),
                  onCheckboxTap: (_) => _toggleCompletion(taskIndex: index),
                  onFavouriteTap: () => _toggleFavourite(taskIndex: index),
                ),
                separatorBuilder: (context, index) => const Divider(),
              ),
      ),
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
      builder: (context) => const TaskCreationDialog(),
    );

    if (enteredText != null) {
      if (mounted) {
        _tasks.add(Task(title: enteredText));
        _filter();
      }
    }
  }

  Future<void> _showEditBranchDialog() async {
    final enteredText = await showDialog<String>(
      context: context,
      builder: (context) => RenameBranchDialog(branchTitle: _title),
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
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Отмена")),
          TextButton(
              onPressed: _deleteCompletedTasks,
              child: const Text('Подтвердить')),
        ],
      ),
    );
  }

  void _toggleCompletion({required int taskIndex}) {
    final index = _tasks
        .indexWhere((element) => element.id == _filteredTasks[taskIndex].id);

    setState(() {
      _tasks[index] =
          _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    });

    if (_isCompletedFilter || _isFavoriteFilter) {
      _filter();
    }
  }

  void _toggleFavourite({required int taskIndex}) {
    final index = _tasks
        .indexWhere((element) => element.id == _filteredTasks[taskIndex].id);

    setState(() {
      _tasks[index] =
          _tasks[index].copyWith(isFavourite: !_tasks[index].isFavourite);
    });

    if (_isFavoriteFilter || _isCompletedFilter) {
      _filter();
    }
  }

  void _deleteTask({required int taskIndex}) {
    setState(() {
      _tasks
          .removeWhere((element) => element.id == _filteredTasks[taskIndex].id);
      _filter();
    });
  }

  void _deleteCompletedTasks() {
    _tasks.removeWhere((task) => task.isCompleted);
    _filter();
    Navigator.of(context).pop();
  }

  void _onFavoriteFilter() {
    setState(() {
      _isFavoriteFilter = !_isFavoriteFilter;
    });
    _filter();
  }

  void _onCompletedFilter() {
    setState(() {
      _isCompletedFilter = !_isCompletedFilter;
    });
    _filter();
  }

  void _filter() {
    if (_isCompletedFilter && _isFavoriteFilter) {
      setState(() {
        _filteredTasks = _tasks
            .where(
                (task) => task.isFavourite == true && task.isCompleted == false)
            .toList();
      });
    } else if (_isCompletedFilter) {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task.isCompleted == false).toList();
      });
    } else if (_isFavoriteFilter) {
      setState(() {
        _filteredTasks =
            _tasks.where((task) => task.isFavourite == true).toList();
      });
    } else {
      setState(() {
        _filteredTasks = _tasks;
      });
    }
  }
}
