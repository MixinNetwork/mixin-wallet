// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $authRoute,
      $homeRoute,
    ];

RouteBase get $authRoute => GoRouteData.$route(
      path: '/auth',
      factory: $AuthRouteExtension._fromState,
    );

extension $AuthRouteExtension on AuthRoute {
  static AuthRoute _fromState(GoRouterState state) => AuthRoute(
        state.uri.queryParameters['code'],
      );

  String get location => GoRouteData.$location(
        '/auth',
        queryParams: {
          if (code != null) 'code': code,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'tokens/:tid',
          factory: $AssetDetailRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'snapshots/:sid',
          factory: $SnapshotDetailRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'withdrawal/:id',
          factory: $AssetWithdrawalRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'transactions',
          factory: $WithdrawalTransactionRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'deposit/:id',
          factory: $AssetDepositRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'setting',
          factory: $SettingRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'transactions',
              factory: $AllTransactionsRouteExtension._fromState,
            ),
            GoRouteData.$route(
              path: 'hiddenAssets',
              factory: $HiddenAssetsRouteExtension._fromState,
            ),
          ],
        ),
        GoRouteData.$route(
          path: 'collection/:cid',
          factory: $CollectiblesCollectionRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'collectible/:itemId',
          factory: $CollectibleDetailRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: '*',
          factory: $NotFoundRouteExtension._fromState,
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => HomeRoute(
        sort: state.uri.queryParameters['sort'],
        tab: state.uri.queryParameters['tab'],
      );

  String get location => GoRouteData.$location(
        '/',
        queryParams: {
          if (sort != null) 'sort': sort,
          if (tab != null) 'tab': tab,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AssetDetailRouteExtension on AssetDetailRoute {
  static AssetDetailRoute _fromState(GoRouterState state) => AssetDetailRoute(
        state.pathParameters['tid']!,
        filterBy: state.uri.queryParameters['filter-by'],
        sortBy: state.uri.queryParameters['sort-by'],
      );

  String get location => GoRouteData.$location(
        '/tokens/${Uri.encodeComponent(tid)}',
        queryParams: {
          if (filterBy != null) 'filter-by': filterBy,
          if (sortBy != null) 'sort-by': sortBy,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SnapshotDetailRouteExtension on SnapshotDetailRoute {
  static SnapshotDetailRoute _fromState(GoRouterState state) =>
      SnapshotDetailRoute(
        state.pathParameters['sid']!,
      );

  String get location => GoRouteData.$location(
        '/snapshots/${Uri.encodeComponent(sid)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AssetWithdrawalRouteExtension on AssetWithdrawalRoute {
  static AssetWithdrawalRoute _fromState(GoRouterState state) =>
      AssetWithdrawalRoute(
        state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/withdrawal/${Uri.encodeComponent(id)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $WithdrawalTransactionRouteExtension on WithdrawalTransactionRoute {
  static WithdrawalTransactionRoute _fromState(GoRouterState state) =>
      WithdrawalTransactionRoute(
        state.uri.queryParameters['id']!,
        destination: state.uri.queryParameters['destination'],
        tag: state.uri.queryParameters['tag'],
        opponentId: state.uri.queryParameters['opponent-id'],
      );

  String get location => GoRouteData.$location(
        '/transactions',
        queryParams: {
          'id': id,
          if (destination != null) 'destination': destination,
          if (tag != null) 'tag': tag,
          if (opponentId != null) 'opponent-id': opponentId,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AssetDepositRouteExtension on AssetDepositRoute {
  static AssetDepositRoute _fromState(GoRouterState state) => AssetDepositRoute(
        state.pathParameters['id']!,
      );

  String get location => GoRouteData.$location(
        '/deposit/${Uri.encodeComponent(id)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingRouteExtension on SettingRoute {
  static SettingRoute _fromState(GoRouterState state) => const SettingRoute();

  String get location => GoRouteData.$location(
        '/setting',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AllTransactionsRouteExtension on AllTransactionsRoute {
  static AllTransactionsRoute _fromState(GoRouterState state) =>
      AllTransactionsRoute(
        filterBy: state.uri.queryParameters['filter-by'],
        rangeType: state.uri.queryParameters['range-type'],
        start: state.uri.queryParameters['start'],
        end: state.uri.queryParameters['end'],
        asset: state.uri.queryParameters['asset'],
      );

  String get location => GoRouteData.$location(
        '/setting/transactions',
        queryParams: {
          if (filterBy != null) 'filter-by': filterBy,
          if (rangeType != null) 'range-type': rangeType,
          if (start != null) 'start': start,
          if (end != null) 'end': end,
          if (asset != null) 'asset': asset,
        },
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HiddenAssetsRouteExtension on HiddenAssetsRoute {
  static HiddenAssetsRoute _fromState(GoRouterState state) =>
      const HiddenAssetsRoute();

  String get location => GoRouteData.$location(
        '/setting/hiddenAssets',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CollectiblesCollectionRouteExtension on CollectiblesCollectionRoute {
  static CollectiblesCollectionRoute _fromState(GoRouterState state) =>
      CollectiblesCollectionRoute(
        state.pathParameters['cid']!,
      );

  String get location => GoRouteData.$location(
        '/collection/${Uri.encodeComponent(cid)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CollectibleDetailRouteExtension on CollectibleDetailRoute {
  static CollectibleDetailRoute _fromState(GoRouterState state) =>
      CollectibleDetailRoute(
        state.pathParameters['itemId']!,
      );

  String get location => GoRouteData.$location(
        '/collectible/${Uri.encodeComponent(itemId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NotFoundRouteExtension on NotFoundRoute {
  static NotFoundRoute _fromState(GoRouterState state) => const NotFoundRoute();

  String get location => GoRouteData.$location(
        '/*',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
