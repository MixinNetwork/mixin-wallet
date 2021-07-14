import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:moor/moor.dart';

import '../db/dao/snapshot_dao.dart';
import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import '../util/extension/extension.dart';
import '../util/logger.dart';
import 'auth/auth.dart';
import 'auth/auth_manager.dart';

const clientId = 'd0a44d9d-bb19-403c-afc5-ea26ea88123b';
const clientSecret =
    '29c9774449f38accd015638d463bc4f70242ecc39e154b939d47017ca9316420';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices() {
    client = sdk.Client(accessToken: accessToken);
    initDbFuture = _initDatabase();
    initDbFuture?.whenComplete(() {
      initDbFuture = null;
    });
  }

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
        .post(sdk.OauthRequest(clientId, clientSecret, oauthCode));

    final scope = response.data.scope;
    if (!scope.contains('ASSETS:READ') || !scope.contains('SNAPSHOTS:READ')) {
      throw ArgumentError('scope');
    }

    final token = response.data.accessToken;

    final _client = sdk.Client(accessToken: token);

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
    return mixinDatabase.assetDao.assetResults(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> assetResult(String assetId) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResult(auth!.account.fiatCurrency, assetId);
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

    return () => mixinDatabase.userDao.insertAll(users.data
        .map((user) => User(
            userId: user.userId,
            identityNumber: user.identityNumber,
            relationship: user.relationship,
            fullName: user.fullName,
            avatarUrl: user.avatarUrl,
            phone: user.phone,
            isVerified: user.isVerified,
            appId: user.app?.appId,
            biography: user.biography,
            muteUntil: DateTime.tryParse(user.muteUntil),
            isScam: user.isScam ? 1 : 0,
            createdAt: user.createdAt))
        .toList());
  }

  Future<void> updateSnapshots(
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

  Future<void> updateSnapshotById({required String snapshotId}) async {
    final data = await client.snapshotApi.getSnapshotById(snapshotId);

    final closures = await Future.wait([
      _checkUsersExistWithReturnInsert([data.data.opponentId!]),
      _checkAssetExistWithReturnInsert(data.data.assetId),
    ]);

    await mixinDatabase.transaction(() async {
      await Future.wait([
        mixinDatabase.snapshotDao.insertAll([data.data]),
        ...closures.map((e) => e?.call()),
      ].where((element) => element != null).cast<Future>());
    });
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
        .where(existHashSets.contains)
        .map((e) => e.toSnapshot(assetId))
        .toList();
    await mixinDatabase.snapshotDao.insertPendingDeposit(snapshots);
  }

  Selectable<Addresse> addresses(String assetId) {
    assert(isLogin);
    return mixinDatabase.addressDao.addressesByAssetId(assetId);
  }

  Future<void> updateAddresses(String assetId) async {
    final addresses =
        (await client.addressApi.getAddressesByAssetId(assetId)).data;
    await mixinDatabase.addressDao.insertAllOnConflictUpdate(addresses);
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
}
