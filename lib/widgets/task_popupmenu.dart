import 'package:flutter/material.dart';

class TaskPopUpMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onTaskDelete;
  final VoidCallback onStepsDelete;

  const TaskPopUpMenu({
    Key? key,
    required this.onEdit,
    required this.onTaskDelete,
    required this.onStepsDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) => value(),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: onEdit,
          child: const ListTile(
            leading: Icon(Icons.mode_edit_outline_outlined),
            title: Text('Редактировать'),
          ),
        ),
        PopupMenuItem(
          value: onTaskDelete,
          child: const ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Удалить задачу'),
          ),
        ),
        PopupMenuItem(
          value: onStepsDelete,
          child: const ListTile(
            leading: Icon(Icons.delete_sweep_outlined),
            title: Text('Удалить выполненные шаги'),
          ),
        ),
      ],
    );
  }
}
