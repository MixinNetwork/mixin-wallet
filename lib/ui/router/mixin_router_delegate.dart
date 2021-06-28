import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_wallet/ui/page/home.dart';
import 'package:mixin_wallet/ui/page/not_found.dart';
import 'package:mixin_wallet/ui/page/some_detail.dart';

class MixinRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final _history = <MapEntry<Uri, Page>>[];

  @override
  Uri get currentConfiguration {
    if (_history.isNotEmpty) return _history.last.key;
    return Uri(path: '/');
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [
          if (_history.isEmpty) _handleUri(Uri(path: '/'))!,
          if (_history.isNotEmpty) ..._history.map((e) => e.value)
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          if (_history.isNotEmpty) _history.removeLast();

          notifyListeners();

          return true;
        },
      );

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey();

  void pushNewUri(Uri uri) {
    setNewRoutePath(uri);
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) {
    print(
        'setNewRoutePath fuck uri: $configuration, path: ${configuration.path}');

    final page = _handleUri(configuration);
    if (page != null) {
      _history.add(MapEntry(configuration, page));
    } else {
      _history.add(
        MapEntry(
          Uri(path: '404'),
          const MaterialPage(
            child: NotFoundPage(),
          ),
        ),
      );
    }

    return SynchronousFuture<void>(null);
  }

  Page? _handleUri(Uri configuration) {
    var path = configuration.path.trim();
    print(
        '_handleUri fuck uri: $configuration, path: $path, path == /: ${path == '/'}');

    if (path == '/') {
      return const MaterialPage(
        child: Home(),
      );
    } else if (path == '/SomeDetail') {
      return const MaterialPage(
        child: SomeDetail(),
      );
    }

    return null;
  }
}
