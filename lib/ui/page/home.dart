import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../main.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('home')
    ),
        body: Center(
          child: TextButton(
            onPressed: (){
              mixinRouterDelegate.setNewRoutePath(Uri(path: '/SomeDetail'));
            },
            child: Text('go some detail'),
          ),
        ),
      );
}
