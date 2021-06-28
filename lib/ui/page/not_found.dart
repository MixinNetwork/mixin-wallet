import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotFound extends StatelessWidget {
  const NotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('404'),
        ),
      );
}
