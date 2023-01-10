import 'package:flutter/material.dart';

class BranchPopUpMenu extends StatelessWidget {
  final bool isShowCompleted;
  final bool isShowFavorite;
  final VoidCallback onCompleted;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BranchPopUpMenu({
    Key? key,
    required this.isShowCompleted,
    required this.isShowFavorite,
    required this.onCompleted,
    required this.onFavorite,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) => value(),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: onCompleted,
          child: isShowCompleted
              ? const ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Показать выполненные'),
                )
              : const ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Скрыть выполненные'),
                ),
        ),
        PopupMenuItem(
          value: onFavorite,
          child: isShowFavorite
              ? const ListTile(
                  leading: Icon(Icons.star_border),
                  title: Text('Все задачи'),
                )
              : const ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Только избранные'),
                ),
        ),
        PopupMenuItem(
          value: onDelete,
          child: const ListTile(
            leading: Icon(Icons.delete),
            title: Text("Удалить выполненные"),
          ),
        ),
        PopupMenuItem(
          value: onEdit,
          child: const ListTile(
            leading: Icon(Icons.edit),
            title: Text("Редактировать ветку"),
          ),
        ),
      ],
    );
  }
}
