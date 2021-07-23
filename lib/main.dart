import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import 'service/app_services.dart';
import 'service/profile/profile_manager.dart';
import 'ui/brightness_theme_data.dart';
import 'ui/router/mixin_routes.dart';
import 'ui/widget/brightness_observer.dart';
import 'util/l10n.dart';
import 'util/logger.dart';

Future<void> main() async {
  if (kReleaseMode) {
    await dotenv.load(fileName: '.prodution.env');
  } else {
    await dotenv.load(fileName: '.env');
  }
  await initStorage();
  runZonedGuarded(
    () => runApp(MyApp()),
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
  MyApp({Key? key}) : super(key: key);

  final vRouterStateKey = GlobalKey<VRouterState>();

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => AppServices(
              vRouterStateKey: vRouterStateKey,
            ),
          ),
        ],
        child: _Router(vRouterStateKey: vRouterStateKey),
      );
}

class _Router extends StatelessWidget {
  const _Router({
    required this.vRouterStateKey,
    Key? key,
  }) : super(key: key);

  final GlobalKey<VRouterState> vRouterStateKey;

  @override
  Widget build(BuildContext context) => VRouter(
        key: vRouterStateKey,
        title: 'Mixin Wallet',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          ...L10n.delegate.supportedLocales,
        ],
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            },
          ),
        ),
        builder: (BuildContext context, Widget child) => DefaultTextStyle(
          style: const TextStyle(height: 1),
          child: BrightnessObserver(
            lightThemeData: lightBrightnessThemeData,
            child: child,
          ),
        ),
        routes: buildMixinRoutes(context),
      );
}
