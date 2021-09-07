import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';
import 'package:vrouter/vrouter.dart';

import '../db/dao/snapshot_dao.dart';
import '../db/dao/user_dao.dart';
import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import '../util/extension/extension.dart';
import '../util/logger.dart';
import 'env.dart';
import 'profile/auth.dart';
import 'profile/profile_manager.dart';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices({
    required this.vRouterStateKey,
  }) {
    client = sdk.Client(
        accessToken: accessToken,
        interceptors: interceptors,
        httpLogLevel: sdk.HttpLogLevel.none);
    initDbFuture = _initDatabase();
    initDbFuture?.whenComplete(() {
      initDbFuture = null;
    });
  }

  List<InterceptorsWrapper> get interceptors => [
        InterceptorsWrapper(
          onError: (
            DioError e,
            ErrorInterceptorHandler handler,
          ) async {
            if (e is sdk.MixinApiError &&
                (e.error as sdk.MixinError).code == sdk.authentication) {
              i('api error code is 401 ');
              await setAuth(null);
              vRouterStateKey.currentState?.to('/auth', isReplacement: true);
            }
            handler.next(e);
          },
        )
      ];

  final GlobalKey<VRouterState> vRouterStateKey;
  late sdk.Client client;
  Future? initDbFuture;
  MixinDatabase? _mixinDatabase;

  bool get databaseInitialized => _mixinDatabase != null;

  MixinDatabase get mixinDatabase {
    if (!databaseInitialized) {
      throw StateError('the database is not initialized');
    }
    return _mixinDatabase!;
  }

  Future<void> login(String oauthCode) async {
    final response = await client.oauthApi
        .post(sdk.OauthRequest(Env.clientId, Env.clientSecret, oauthCode));

    final scope = response.data.scope;
    if (!scope.contains('ASSETS:READ') || !scope.contains('SNAPSHOTS:READ')) {
      throw ArgumentError('scope');
    }

    final token = response.data.accessToken;

    final _client = sdk.Client(accessToken: token, interceptors: interceptors);

    final mixinResponse = await _client.accountApi.getMe();

    await setAuth(Auth(accessToken: token, account: mixinResponse.data));

    client = _client;
    await _initDatabase();
    notifyListeners();
  }

  Future<void> _initDatabase() async {
    if (accessToken == null) return;
    i('init database start');
    _mixinDatabase = await constructDb(auth!.account.identityNumber);
    i('init database done');
    notifyListeners();
  }

  Future<void> updateAssets() async {
    final list = await Future.wait([
      client.assetApi.getAssets(),
      client.accountApi.getFiats(),
    ]);
    final assets = (list.first as sdk.MixinResponse<List<sdk.Asset>>).data;
    final fiats = (list.last as sdk.MixinResponse<List<sdk.Fiat>>).data;

    await mixinDatabase.transaction(() async {
      await mixinDatabase.assetDao.resetAllBalance();
      await mixinDatabase.assetDao.insertAllOnConflictUpdate(assets);
      await mixinDatabase.fiatDao.insertAllOnConflictUpdate(fiats);
    });
  }

  Future<sdk.Asset> updateAsset(String assetId) async {
    final asset = (await client.assetApi.getAssetById(assetId)).data;
    await mixinDatabase.assetDao.insert(asset);
    return asset;
  }

  Selectable<AssetResult> assetResults() {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResultsNotHidden(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> searchAssetResults(String keyword) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .searchAssetResults(auth!.account.fiatCurrency, keyword);
  }

  Selectable<AssetResult> assetResult(String assetId) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId);
  }

  Selectable<AssetResult> hiddenAssetResult() {
    assert(isLogin);
    return mixinDatabase.assetDao.hiddenAssets(auth!.account.fiatCurrency);
  }

  Future<void> updateAssetHidden(String assetId, {required bool hidden}) {
    assert(isLogin);
    return mixinDatabase.assetsExtraDao.updateHidden(assetId, hidden);
  }

  Future<Future<void> Function()?> _checkAssetExistWithReturnInsert(
      String assetId) async {
    if (await mixinDatabase.assetDao
            .simpleAssetById(assetId)
            .getSingleOrNull() !=
        null) {
      return null;
    }

    final asset = (await client.assetApi.getAssetById(assetId)).data;
    return () => mixinDatabase.assetDao.insert(asset);
  }

  Future<Future<void> Function()?> _checkUsersExistWithReturnInsert(
      List<String> userIds) async {
    if (userIds.isEmpty) return null;

    final userNeedFetch = userIds.toList();
    final existUsers =
        (await mixinDatabase.userDao.findExistsUsers(userIds).get()).toSet();
    userNeedFetch.removeWhere(existUsers.contains);

    if (userNeedFetch.isEmpty) return null;

    final users = await client.userApi.getUsers(userNeedFetch);

    return () => mixinDatabase.userDao
        .insertAll(users.data.map((user) => user.toDbUser()).toList());
  }

  Future<void> updateAssetSnapshots(
    String assetId, {
    String? offset,
    int limit = 30,
  }) async {
    final result = await Future.wait([
      client.snapshotApi.getSnapshotsByAssetId(
        assetId,
        offset: offset,
        limit: limit,
      ),
      _checkAssetExistWithReturnInsert(assetId),
    ]);
    final response = result[0]! as sdk.MixinResponse<List<sdk.Snapshot>>;
    final insertAsset = result[1] as Future<void> Function()?;

    final insertUsers = await _checkUsersExistWithReturnInsert(
        response.data.map((e) => e.opponentId).whereNotNull().toList());

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(response.data),
        insertUsers?.call(),
        insertAsset?.call(),
      ].where((element) => element != null).cast<Future>());
    });
  }

  Future<List<SnapshotItem>> getSnapshots({
    required String assetId,
    String? offset,
    int limit = 30,
    String? opponent,
    String? destination,
    String? tag,
  }) async {
    final result = await Future.wait([
      client.snapshotApi.getSnapshots(
        assetId: assetId,
        offset: offset,
        limit: limit,
        opponent: opponent,
        destination: destination,
        tag: tag,
      ),
      _checkAssetExistWithReturnInsert(assetId),
    ]);
    final response = result[0]! as sdk.MixinResponse<List<sdk.Snapshot>>;
    final insertAsset = result[1] as Future<void> Function()?;

    final insertUsers = await _checkUsersExistWithReturnInsert(
        response.data.map((e) => e.opponentId).whereNotNull().toList());
    return mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(response.data),
        insertUsers?.call(),
        insertAsset?.call(),
      ].where((element) => element != null).cast<Future>());
      return mixinDatabase.snapshotDao
          .snapshotsByIds(response.data.map((e) => e.snapshotId).toList())
          .get();
    });
  }

  Future<void> updateAllSnapshots({
    String? offset,
    String? opponent,
    int limit = 30,
  }) async {
    final snapshots = await client.snapshotApi
        .getSnapshots(offset: offset, limit: limit, opponent: opponent)
        .then((value) => value.data);

    final closures = [
      await _checkUsersExistWithReturnInsert(
          snapshots.map((e) => e.opponentId).toSet().whereNotNull().toList()),
      for (final assetId in snapshots.map((e) => e.assetId).toSet())
        await _checkAssetExistWithReturnInsert(assetId)
    ];

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll(snapshots),
        ...closures.map((e) => e?.call())
      ].whereNotNull());
    });
  }

  Future<void> updateSnapshotById({required String snapshotId}) async {
    final data = await client.snapshotApi.getSnapshotById(snapshotId);

    final closures = await Future.wait([
      _checkUsersExistWithReturnInsert(
        [data.data.opponentId].whereNotNull().toList(),
      ),
      _checkAssetExistWithReturnInsert(data.data.assetId),
    ]);

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll([data.data]),
        ...closures.map((e) => e?.call()),
      ].where((element) => element != null).cast<Future>());
    });
  }

  Future<bool> updateSnapshotByTraceId({required String traceId}) async {
    try {
      final data = await client.snapshotApi.getSnapshotByTraceId(traceId);
      final closures = await Future.wait([
        _checkUsersExistWithReturnInsert(
          [data.data.opponentId].whereNotNull().toList(),
        ),
        _checkAssetExistWithReturnInsert(data.data.assetId),
      ]);
      await mixinDatabase.transaction(() async {
        await Future.wait([
          mixinDatabase.snapshotDao.insertAll([data.data]),
          ...closures.map((e) => e?.call()),
        ].whereNotNull().cast<Future>());
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshPendingDeposits(AssetResult asset) =>
      _refreshPendingDeposits(asset.assetId, asset.destination, asset.tag);

  Future<void> _refreshPendingDeposits(
    String assetId,
    String? assetDestination,
    String? assetTag,
  ) async {
    if (assetDestination?.isNotEmpty == true) {
      final ret = await client.assetApi.pendingDeposits(
        assetId,
        destination: assetDestination,
        tag: assetTag,
      );
      await mixinDatabase.snapshotDao.clearPendingDepositsByAssetId(assetId);
      if (ret.data.isEmpty) {
        return;
      }
      await _processPendingDeposit(assetId, ret.data);
    } else {
      final asset = await updateAsset(assetId);
      assert(asset.destination != null);
      await _refreshPendingDeposits(
          asset.assetId, asset.destination, asset.tag);
    }
  }

  Future<void> _processPendingDeposit(
      String assetId, List<sdk.PendingDeposit> pendingDeposits) async {
    final hashList = pendingDeposits.map((e) => e.transactionHash).toList();
    final existHashSets = (await mixinDatabase.snapshotDao
            .snapshotIdsByTransactionHashList(assetId, hashList)
            .get())
        .toSet();
    final snapshots = pendingDeposits
        .where((e) => !existHashSets.contains(e.transactionHash))
        .map((e) => e.toSnapshot(assetId))
        .toList();
    await mixinDatabase.snapshotDao.insertPendingDeposit(snapshots);
  }

  Selectable<Addresse> addresses(String assetId) {
    assert(isLogin);
    return mixinDatabase.addressDao.addressesByAssetId(assetId);
  }

  Future<List<sdk.Address>> updateAddresses(String assetId) async {
    final addresses =
        (await client.addressApi.getAddressesByAssetId(assetId)).data;
    await mixinDatabase.addressDao.insertAllOnConflictUpdate(addresses);
    return addresses;
  }

  Selectable<User> friends() => mixinDatabase.findFriendsNotBot();

  Future<void> updateFriends() async {
    assert(isLogin);
    try {
      final friends = await client.accountApi.getFriends();
      await mixinDatabase.userDao
          .insertAll(friends.data.map((e) => e.toDbUser()).toList());
    } on DioError catch (e) {
      if (e.optionMixinError?.isForbidden == true) {
        rethrow;
      }
      d('update friends failed: $e');
    } catch (e) {
      d('update friends failed: $e');
    }
  }

  Future<User?> getUserById(String id) async {
    if (id.isEmpty) {
      return null;
    }
    final cb = await _checkUsersExistWithReturnInsert([id]);
    await cb?.call();
    return mixinDatabase.userDao.userById(id).getSingleOrNull();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final __mixinDatabase = _mixinDatabase;
    _mixinDatabase = null;
    await __mixinDatabase?.close();
  }

  @override
  List<Object?> get props => [
        client,
        _mixinDatabase,
      ];

  Future<void> searchAndUpdateAsset(String keyword) async {
    if (keyword.isEmpty) return;
    final mixinResponse = await client.assetApi.queryAsset(keyword);
    await mixinDatabase.assetDao.insertAllOnConflictUpdate(mixinResponse.data);
  }

  Future<void> updateTopAssetIds() async {
    final list = (await client.assetApi.getTopAssets()).data;
    // todo update, now balance always 0
    // unawaited(mixinDatabase.assetDao.insertAllOnConflictUpdate(list));
    final assetIds = list.map((e) => e.assetId).toList();
    replaceTopAssetIds(assetIds);
  }

  Stream<List<AssetResult>> watchAssetResultsOfIn(Iterable<String> assetIds) =>
      mixinDatabase.assetDao
          .assetResultsOfIn(auth!.account.fiatCurrency, assetIds)
          .watch()
          .map((list) {
        final map = Map.fromEntries(list.map((e) => MapEntry(e.assetId, e)));
        return assetIds
            .map(map.remove)
            .where((element) => element != null)
            .cast<AssetResult>()
            .toList();
      });

  Future<List<AssetResult>> findOrSyncAssets(List<String> assetIds) =>
      Future.wait(assetIds.map(findOrSyncAsset)).then(
          (list) => list.where((e) => e != null).cast<AssetResult>().toList());

  Future<AssetResult?> findOrSyncAsset(String assetId) async {
    assert(isLogin);
    final result = await mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId)
        .getSingleOrNull();
    if (result != null) return result;

    final asset = (await client.assetApi.getAssetById(assetId)).data;
    await mixinDatabase.assetDao.insert(asset);
    return mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId)
        .getSingleOrNull();
  }
}
