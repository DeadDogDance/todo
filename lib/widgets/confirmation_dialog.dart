import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String description;
  final VoidCallback onOk;
  final String title;

  const ConfirmationDialog({
    Key? key,
    required this.description,
    required this.onOk,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onOk();
          },
          child: const Text('Подтвердить'),
        ),
      ],
    );
  }
}
