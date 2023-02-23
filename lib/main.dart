import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:vrouter/vrouter.dart';

import 'service/account_provider.dart';
import 'service/app_services.dart';
import 'service/profile/profile_manager.dart';
import 'ui/brightness_theme_data.dart';
import 'ui/router/mixin_routes.dart';
import 'ui/widget/brightness_observer.dart';
import 'ui/widget/error_widget.dart';
import 'util/l10n.dart';
import 'util/logger.dart';
import 'util/mixin_context.dart';
import 'util/web/telegram_web_app.dart';
import 'util/web/web_utils.dart';

final navigatorObserver = RouteObserver<ModalRoute<dynamic>>();

Future<void> main() async {
  await initStorage();

  final mixinLocale = getMixinLocale();
  i('mixinLocale: $mixinLocale');
  if (mixinLocale != null) {
    await L10n.delegate.load(mixinLocale);
  }

  ErrorWidget.builder = MixinErrorWidget.defaultErrorWidgetBuilder;

  runZonedGuarded(
    () => runApp(OverlaySupport.global(child: MyApp())),
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

class MyApp extends HookWidget {
  MyApp({super.key});

  final vRouterStateKey = GlobalKey<VRouterState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = useMemoized(AuthProvider.new);

    useEffect(
      () {
        if (!authProvider.isLoginByCredential) {
          return;
        }
        final loginTgUserId = authProvider.value?.credential?.userId;
        if (loginTgUserId == null) {
          return;
        }
        try {
          final currentTgUserId = Telegram.instance.getTgUserId();
          // check is the same telegram user.
          if (currentTgUserId != loginTgUserId) {
            i('logout: current: $currentTgUserId, login: $loginTgUserId');
            authProvider.clear();
          }
        } catch (error, stacktrace) {
          e('getTgUserId error: $error $stacktrace');
        }
      },
      [authProvider],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => AppServices(
            vRouterStateKey: vRouterStateKey,
            authProvider: authProvider,
          ),
        ),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: _Router(vRouterStateKey: vRouterStateKey),
    );
  }
}

class _Router extends StatelessWidget {
  const _Router({
    required this.vRouterStateKey,
  });

  final GlobalKey<VRouterState> vRouterStateKey;

  @override
  Widget build(BuildContext context) => VRouter(
        key: vRouterStateKey,
        title: 'Mixin Wallet',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [navigatorObserver],
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
              TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
              TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
            },
          ),
          fontFamily: getFallbackFontFamily(),
        ),
        builder: (BuildContext context, Widget child) => DefaultTextStyle(
          style: TextStyle(
            height: 1,
            // Add underline decoration for Safari.
            // https://github.com/flutter/flutter/issues/90705#issuecomment-927944039
            // because Chinese/Japanese characters can not render in latest safari(iOS15).
            decoration: defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.macOS
                ? TextDecoration.underline
                : null,
          ),
          child: BrightnessObserver(
            lightThemeData: lightBrightnessThemeData,
            child: child,
          ),
        ),
        routes: buildMixinRoutes(context),
      );
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder() : super();

  @override
  Widget buildTransitions<T>(
          PageRoute<T> route,
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) =>
      child;
}
