import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskCreationDialog extends StatefulWidget {
  const TaskCreationDialog({Key? key}) : super(key: key);

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать задачу'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: controller,
          validator: (value) {
            if (value == null || value.isEmpty || value.trim().isEmpty) {
              return 'Название не может быть пустым';
            } else if (value.length > 40) {
              return 'Слишком длинное название';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: 'Введите название задачи',
          ),
          maxLength: 40,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          minLines: 1,
          maxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Отмена"),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(controller.text);
            }
          },
          child: const Text('Ок'),
        ),
      ],
    );
  }
}
