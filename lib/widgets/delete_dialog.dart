import 'package:flutter/material.dart';

class TaskCreationDialog extends StatefulWidget {
  const TaskCreationDialog({Key? key}) : super(key: key);

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтвердите удаление'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop,
          child: const Text("Отмена"),
        ),
        TextButton(onPressed: () {}, child: const Text('Подтвердить')),
      ],
    );
  }
}
