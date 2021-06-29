import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/web/web_util.dart';
import '../page/auth.dart';
import '../page/home.dart';
import '../page/not_found.dart';

class MixinRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final _history = <MapEntry<Uri, MixinPage>>[];

  static final homeUri = Uri(path: '/');
  static final authUri = Uri(path: '/auth');
  static final notFoundUri = Uri(path: '/404');

  @override
  Uri get currentConfiguration {
    i('currentConfiguration: $_history');

    if (_history.isNotEmpty) return _history.last.key;
    return homeUri;
  }

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<MixinRouterDelegate>(
        create: (context) => this,
        child: Navigator(
          key: navigatorKey,
          pages: [
            if (_history.isEmpty) routerMap()['$homeUri']!.rebuild(),
            ..._history.map((e) => e.value)
          ],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }

            if (_history.isNotEmpty) _history.removeLast();

            notifyListeners();

            return true;
          },
        ),
      );

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey();

  void replaceLast(Uri uri) {
    i('replaceLast: $uri');

    if (kIsWeb) return replaceUrl('$uri');
    if (_history.isNotEmpty) _history.removeLast();
    pushNewUri(uri);
  }

  Future<void> pushNewUri(Uri uri) async {
    i('pushNewUri: $uri');

    await setNewRoutePath(uri);
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) {
    i('setNewRoutePath: $configuration');

    if (kIsWeb) _history.clear();
    _history.add(_handleUri(configuration));
    return SynchronousFuture(null);
  }

  MapEntry<Uri, MixinPage> _handleUri(Uri configuration) {
    final path = configuration.path.trim();
    final box = Hive.box('settings');

    var uri = configuration;
    MixinPage? page;
    Map<String, String>? pathParameters;
    final accessToken = box.get('access_token');

    final map = routerMap();
    if (accessToken == null) {
      page = map['$authUri'];
      uri = authUri.pathMatch(uri) ? uri : authUri;
    } else {
      for (final item in map.entries) {
        if (!item.key.pathMatch(path)) continue;

        pathParameters = item.key.extractPathParameters(path);
        page = item.value;
      }
    }

    page ??= map['$notFoundUri']!;

    return MapEntry(
      uri,
      page.rebuild(
        pathParameters: pathParameters,
        queryParameters: uri.queryParameters,
      ),
    );
  }

  Map<String, MixinPage> routerMap() => {
        '$homeUri': const MixinPage(
          child: Home(),
        ),
        '$authUri': const MixinPage(
          child: Auth(),
        ),
        '$notFoundUri': const MixinPage(
          child: NotFound(),
        ),
      };
}

class MixinPage extends MaterialPage {
  const MixinPage({
    required Widget child,
    LocalKey? key,
    String? name,
  }) : super(
          child: child,
          key: key,
          name: name,
        );

  MixinPage rebuild({
    Map<String, String>? pathParameters,
    Map<String, String> queryParameters = const {},
  }) =>
      MixinPage(
        key: key,
        name: name,
        child: Provider(
          create: (BuildContext context) => MixinParameter(
            pathParameters: pathParameters ?? {},
            queryParameters: queryParameters,
          ),
          child: child,
        ),
      );
}

class MixinParameter extends Equatable {
  const MixinParameter({
    required this.pathParameters,
    required this.queryParameters,
  });

  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  @override
  List<Object?> get props => [
        pathParameters,
        queryParameters,
      ];
}
