import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

enum Menu { completed, favourite, deleteCompleted, editBranch, all }

var uuid = const Uuid();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class Task {
  bool completed = false;
  String name = '';
  bool favourite = false;
  var id = uuid.v1();

  Task(String input) {
    name = input;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _title = "Учеба";
  late TextEditingController controller;
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  final _formKey = GlobalKey<FormState>();
  Menu currentState = Menu.all;
  List<int> menuIndexes = [0, 1, 2];
  List<PopupMenuItem<Menu>> menus = [
    const PopupMenuItem<Menu>(
        value: Menu.completed,
        child: ListTile(
          leading: Icon(Icons.check_circle),
          title: Text('Только выполненные'),
        )),
    const PopupMenuItem<Menu>(
        value: Menu.favourite,
        child: ListTile(
          leading: Icon(Icons.star),
          title: Text('Только избранные'),
        )),
    const PopupMenuItem<Menu>(
        value: Menu.deleteCompleted,
        child: ListTile(
            leading: Icon(Icons.delete), title: Text("Удалить выполненные"))),
    const PopupMenuItem<Menu>(
        value: Menu.editBranch,
        child: ListTile(
            leading: Icon(Icons.edit), title: Text("Редактировать ветку"))),
  ];
  PopupMenuItem<Menu> hiddenMenu = const PopupMenuItem<Menu>(
      value: Menu.all,
      child: ListTile(
        leading: Icon(Icons.star_border),
        title: Text("Все задачи"),
      ));

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void changeCom(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;
    });
  }

  void addTask() async {
    final name = await addTaskDialog();
    if (name == null) return;
    setState(() {
      tasks.add((Task(name)));
      if (currentState == Menu.all) filter(Menu.all);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(_title),
        actions: <Widget>[
          PopupMenuButton<Menu>(
            onSelected: (value) async {
              if (value == Menu.editBranch) {
                final title = await branchDialog();
                if (title == null) return;
                setState(() {
                  _title = title;
                  currentState = value;
                });
              } else if (value == Menu.deleteCompleted) {
                await deleteDialog();
              } else if (value == Menu.completed) {
                swapMenu(Menu.completed);
                filter(Menu.completed);
              } else if (value == Menu.favourite) {
                swapMenu(Menu.favourite);
                filter(Menu.favourite);
              } else if (value == Menu.all) {
                swapMenu(Menu.all);
                filter(Menu.all);
              }
            },
            itemBuilder: (BuildContext context) => menus,
          )
        ],
      ),
      body: Container(
        child: filteredTasks.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                          'assets/images/todolist_background.svg'),
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/images/todolist.svg')),
                  ]),
                  const SizedBox(
                      width: 120,
                      child: Text(
                        "На данный момент задачи отсутствуют",
                        textAlign: TextAlign.center,
                      ))
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                itemCount: filteredTasks.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  final task = filteredTasks[i];

                  return Dismissible(
                    direction: DismissDirection.endToStart,
                    key: ValueKey<String>(task.id),
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment(0.95, 0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: ListTile(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(5),
                              right: Radius.circular(5))),
                      tileColor: Colors.white,
                      title: Text(task.name),
                      leading: Checkbox(
                        hoverColor: Colors.grey,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.purple.withOpacity(.32);
                          }
                          return Colors.purple;
                        }),
                        value: task.completed,
                        shape: const CircleBorder(),
                        onChanged: (value) {
                          changeCom(i);
                          if (currentState == Menu.completed) {
                            filter(Menu.completed);
                          }
                        },
                      ),
                      trailing: IconButton(
                        icon: task.favourite
                            ? const Icon(
                                Icons.star,
                                color: Colors.amber,
                              )
                            : const Icon(
                                Icons.star_border,
                                color: Colors.amber,
                              ),
                        onPressed: () {
                          setState(() {
                            task.favourite = !task.favourite;
                            if (currentState == Menu.favourite) {
                              filter(Menu.favourite);
                            }
                          });
                        },
                      ),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        tasks.removeWhere(
                            (element) => element.id == filteredTasks[i].id);
                        filter(currentState);
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> addTaskDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Создать задачу'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
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
            minLines: 1,
            maxLines: 3,
            onFieldSubmitted: (_) => submit(),
          ),
        ),
        actions: [
          TextButton(onPressed: cancel, child: const Text("Отмена")),
          TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submit();
                }
              },
              child: const Text('Ок')),
        ],
      ),
    );
  }

  Future<String?> branchDialog() {
    controller.text = _title;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Редактировать ветку'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Название не может быть пустым';
              } else if (value.length > 40) {
                return 'Слишком длинное название';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Введите название ветки',
            ),
            maxLength: 40,
            minLines: 1,
            maxLines: 3,
            onFieldSubmitted: (_) => submit(),
          ),
        ),
        actions: [
          TextButton(onPressed: cancel, child: const Text("Отмена")),
          TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submit();
                }
              },
              child: const Text('Ок')),
        ],
      ),
    );
  }

  Future deleteDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        actions: [
          TextButton(onPressed: cancel, child: const Text("Отмена")),
          TextButton(
              onPressed: deleteCompleted, child: const Text('Подтвердить')),
        ],
      ),
    );
  }

  void deleteCompleted() {
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].completed) {
        setState(() {
          filteredTasks.removeWhere((element) => element.id == tasks[i].id);
          tasks.removeAt(i);
        });
        i--;
      }
    }
    Navigator.of(context).pop();
  }

  void filter(Menu value) {
    if (value == Menu.favourite) {
      setState(() {
        filteredTasks = tasks.where((task) => task.favourite == true).toList();
      });
    } else if (value == Menu.completed) {
      setState(() {
        filteredTasks = tasks.where((task) => task.completed == true).toList();
      });
    } else if (value == Menu.all) {
      setState(() {
        filteredTasks = tasks;
      });
    }
    setState(() {
      currentState = value;
    });
  }

  void cancel() {
    Navigator.of(context).pop();
    controller.clear();
  }

  void submit() {
    Navigator.of(context).pop(controller.text);
    controller.clear();
  }

  void swapMenu(Menu state) {
    if (currentState == Menu.all) {
      if (state == Menu.completed) {
        final temp1 = hiddenMenu;
        hiddenMenu = menus[0];
        menus[0] = temp1;
      } else {
        final temp1 = hiddenMenu;
        hiddenMenu = menus[1];
        menus[1] = temp1;
      }
    } else if (currentState == Menu.completed) {
      final temp1 = hiddenMenu;
      hiddenMenu = menus[0];
      menus[0] = temp1;
      if (state == Menu.favourite) {
        final temp2 = hiddenMenu;
        hiddenMenu = menus[1];
        menus[1] = temp2;
      }
    } else {
      final temp1 = hiddenMenu;
      hiddenMenu = menus[1];
      menus[1] = temp1;
      if (state == Menu.completed) {
        final temp2 = hiddenMenu;
        hiddenMenu = menus[0];
        menus[0] = temp2;
      }
    }
  }
}
