import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/task.dart';

class TaskEditDialog extends StatefulWidget {
  final Task task;

  const TaskEditDialog({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  late bool _isFavourite;

  @override
  void initState() {
    controller.text = widget.task.title;
    _isFavourite = widget.task.isFavourite;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать задачу'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              autofocus: false,
              controller: controller,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Название не может быть пустым';
                } else if (value.length > 40) {
                  return 'Слишком длинное название';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Введите название задачи',
              ),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\n"))],
              maxLengthEnforcement: MaxLengthEnforcement.none,
              maxLength: 40,
              minLines: 1,
              maxLines: 3,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFavourite = !_isFavourite;
                  });
                },
                icon: Icon(
                  _isFavourite ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
              ),
              const Text('Избранное'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(
                Task(
                  id: widget.task.id,
                  title: controller.text,
                  isFavourite: _isFavourite,
                  isCompleted: widget.task.isCompleted,
                  dateOfCreation: widget.task.dateOfCreation,
                  subtaskCount: widget.task.subtaskCount,
                  completedSubtaskCount: widget.task.completedSubtaskCount,
                ),
              );
            }
          },
          child: const Text('Ок'),
        ),
      ],
    );
  }
}
