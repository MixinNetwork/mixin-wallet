import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'dart:html';

import '../page/home.dart';
import '../page/not_found.dart';
import '../page/some_detail.dart';

final notFoundUri = Uri(path: '404');
const notFoundPage = MaterialPage(
  child: NotFound(),
);

class MixinRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  final _history = <MapEntry<Uri, Page>>[];

  static const _homePage = MaterialPage(
    child: Home(),
  );

  @override
  Uri get currentConfiguration {
    if (_history.isNotEmpty) return _history.last.key;
    return Uri(path: '/');
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: [
          if (_history.isEmpty) _homePage,
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
      );

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey();

  Future<void> pushNewUri(Uri uri) async {
    await setNewRoutePath(uri);
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    if (kIsWeb) _history.clear();
    _history.add(await _handleUri(configuration));
  }

  // handle uri, we can check auth here
  Future<MapEntry<Uri, Page>> _handleUri(Uri configuration) async {
    final path = configuration.path.trim();

    late Page page;
    if (path == '/auth') {
      final oauthCode = configuration.queryParameters['code'];
      print(oauthCode);
    } else if (path == '/') {
      final box = Hive.box('settings');
      final accessToken = box.get('access_token');
      if (accessToken == null) {
        const oauthUrl =
            'https://mixin.one/oauth/authorize?client_id=d0a44d9d-bb19-403c-afc5-ea26ea88123b&scope=PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ&response_type=code';
        window.location.replace(oauthUrl);
        // todo oauth page
        page = notFoundPage;
      } else {
        page = _homePage;
      }
    } else if (path == '/asset') {
      page = const MaterialPage(
        child: SomeDetail(),
      );
    } else {
      return MapEntry(notFoundUri, notFoundPage);
    }

    return MapEntry(configuration, page);
  }
}
