import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/assets.dart';

class EmptyBranch extends StatefulWidget {
  const EmptyBranch({Key? key}) : super(key: key);

  @override
  State<EmptyBranch> createState() => _EmptyBranchState();
}

class _EmptyBranchState extends State<EmptyBranch> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: <Widget>[
            Center(
              child: SvgPicture.asset(Assets.todoListBackground),
            ),
            Center(
              child: SvgPicture.asset(Assets.todoList),
            ),
          ],
        ),
        const Text(
          'На данный\n момент задачи\n отсутствуют',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
