import 'package:flutter/material.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'branch_page.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: generateMaterialColor(
          color: const Color(0xff6202ee),
        ),
        scaffoldBackgroundColor: generateMaterialColor(
          color: const Color(0xffb5c9fd),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xff01a39d),
        ),
      ),
      home: const TaskListPage(),
    );
  }
}
