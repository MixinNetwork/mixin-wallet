import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'ui/router/mixin_route_information_parser.dart';
import 'ui/router/mixin_router_delegate.dart';
import 'util/logger.dart';
import 'util/web/web_util.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  configureApp();
  runZonedGuarded(
    () => runApp(const MyApp()),
    (Object error, StackTrace stack) {
      if (!kLogMode) return;
      e('$error, $stack');
    },
    zoneSpecification: ZoneSpecification(
      handleUncaughtError: (_, __, ___, Object error, StackTrace stack) {
        if (!kLogMode) return;
        wtf('$error, $stack');
      },
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        if (!kLogMode) return;
        parent.print(zone, colorizeNonAnsi(line));
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Mixin Wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerDelegate: MixinRouterDelegate(),
        routeInformationParser: MixinRouteInformationParser(),
      );
}
