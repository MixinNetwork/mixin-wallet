import 'package:flutter/material.dart';

import 'ui/router/mixin_route_information_parser.dart';
import 'ui/router/mixin_router_delegate.dart';

void main() {
  runApp(const MyApp());
}

final mixinRouterDelegate = MixinRouterDelegate();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerDelegate: mixinRouterDelegate,
        routeInformationParser: MixinRouteInformationParser(),
      );
}
