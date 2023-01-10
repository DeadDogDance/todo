import 'package:flutter/material.dart';
import 'package:todo/entities/subtask.dart';

class SubtaskCard extends StatelessWidget {
  final Subtask subtask;
  final Function(bool?) onCompleted;
  final Function deleteSubtask;
  final Function(String, String) onSubtaskTextChange;

  const SubtaskCard({
    Key? key,
    required this.subtask,
    required this.onCompleted,
    required this.deleteSubtask,
    required this.onSubtaskTextChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: subtask.text);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: subtask.isCompleted,
            onChanged: onCompleted,
            shape: const CircleBorder(),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Введите шаг',
                border: InputBorder.none,
              ),
              style: TextStyle(
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
              ),
              onChanged: (text) {
                onSubtaskTextChange(subtask.id, text);
              },
            ),
          ),
          IconButton(
            onPressed: () => deleteSubtask(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
