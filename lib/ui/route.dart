import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page/all_transactions.dart';
import 'page/asset_deposit.dart';
import 'page/asset_detail.dart';
import 'page/auth.dart';
import 'page/collectible_detail.dart';
import 'page/collectibles_collection.dart';
import 'page/hidden_assets.dart';
import 'page/home.dart';
import 'page/not_found.dart';
import 'page/setting.dart';
import 'page/snapshot_detail.dart';
import 'page/withdrawal.dart';
import 'page/withdrawal_transactions.dart';

part 'route.g.dart';

@TypedGoRoute<AuthRoute>(path: '/auth')
class AuthRoute extends GoRouteData {
  const AuthRoute([this.code]);

  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AuthPage(oauthCode: code);
}

@TypedGoRoute<HomeRoute>(path: '/', routes: <TypedGoRoute<GoRouteData>>[
  TypedGoRoute<AssetDetailRoute>(path: 'tokens/:tid'),
  TypedGoRoute<SnapshotDetailRoute>(path: 'snapshots/:sid'),
  TypedGoRoute<AssetWithdrawalRoute>(path: 'withdrawal/:id'),
  TypedGoRoute<WithdrawalTransactionRoute>(path: 'transactions'),
  TypedGoRoute<AssetDepositRoute>(path: 'deposit/:id'),
  TypedGoRoute<SettingRoute>(
    path: 'setting',
    routes: [
      TypedGoRoute<AllTransactionsRoute>(path: 'transactions'),
      TypedGoRoute<HiddenAssetsRoute>(path: 'hiddenAssets'),
    ],
  ),
  TypedGoRoute<CollectiblesCollectionRoute>(path: 'collection/:cid'),
  TypedGoRoute<CollectibleDetailRoute>(path: 'collectible/:itemId'),
  TypedGoRoute<NotFoundRoute>(path: 'not_found'),
])
class HomeRoute extends GoRouteData {
  const HomeRoute({
    this.sort,
    this.tab,
  });

  final String? sort;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      Home(sort: sort, tab: tab);
}

class AssetDetailRoute extends GoRouteData {
  const AssetDetailRoute(
    this.tid, {
    this.filterBy,
    this.sortBy,
  });

  final String tid;

  final String? filterBy;
  final String? sortBy;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AssetDetail(asset: tid);
}

class SnapshotDetailRoute extends GoRouteData {
  const SnapshotDetailRoute(this.sid);

  final String sid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SnapshotDetail(snapshotId: sid);
}

class AssetWithdrawalRoute extends GoRouteData {
  const AssetWithdrawalRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      Withdrawal(assetId: id);
}

class WithdrawalTransactionRoute extends GoRouteData {
  const WithdrawalTransactionRoute(this.id,
      {this.destination, this.tag, this.opponentId});

  final String id;
  final String? destination;
  final String? tag;
  final String? opponentId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      WithdrawalTransactions(
        assetId: id,
        destination: destination,
        tag: tag,
        opponentId: opponentId ?? '',
      );
}

class AssetDepositRoute extends GoRouteData {
  const AssetDepositRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AssetDeposit(assetId: id);
}

class SettingRoute extends GoRouteData {
  const SettingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const Setting();
}

class AllTransactionsRoute extends GoRouteData {
  const AllTransactionsRoute({
    this.filterBy,
    this.rangeType,
    this.start,
    this.end,
    this.asset,
  });

  final String? filterBy;
  final String? rangeType;
  final String? start;
  final String? end;
  final String? asset;

  @override
  Widget build(BuildContext context, GoRouterState state) => AllTransactions(
        assetId: asset ?? '',
        filterBy: filterBy,
        rangeType: rangeType,
        start: start ?? '',
        end: end ?? '',
      );
}

class HiddenAssetsRoute extends GoRouteData {
  const HiddenAssetsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HiddenAssets();
}

class CollectiblesCollectionRoute extends GoRouteData {
  const CollectiblesCollectionRoute(this.cid);

  final String cid;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CollectiblesCollection(collectionId: cid);
}

class CollectibleDetailRoute extends GoRouteData {
  const CollectibleDetailRoute(this.itemId);

  final String itemId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CollectibleDetail(tokenId: itemId);
}

class NotFoundRoute extends GoRouteData {
  const NotFoundRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotFound();
}
