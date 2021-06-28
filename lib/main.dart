import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'ui/router/mixin_route_information_parser.dart';
import 'ui/router/mixin_router_delegate.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const MyApp());
}

final mixinRouterDelegate = MixinRouterDelegate();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Mixin Wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerDelegate: mixinRouterDelegate,
        routeInformationParser: MixinRouteInformationParser(),
      );
}
