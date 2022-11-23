import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:pointycastle/digests/sha3.dart';
import 'package:vrouter/vrouter.dart';

import '../db/dao/extension.dart';
import '../db/dao/snapshot_dao.dart';
import '../db/dao/user_dao.dart';
import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import '../thirdy_party/telegram.dart';
import '../util/constants.dart';
import '../util/extension/extension.dart';
import '../util/logger.dart';
import '../util/web/telegram_web_app_dummy.dart'
    if (dart.library.html) '../util/web/telegram_web_app.dart';
import 'env.dart';
import 'profile/auth.dart';
import 'profile/pin_session.dart';
import 'profile/profile_manager.dart';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices({
    required this.vRouterStateKey,
  }) {
    if (isLoginByCredential) {
      final credential = auth!.credential!;
      client = sdk.Client(
        userId: credential.mixinId,
        sessionId: credential.sessionId,
        privateKey: credential.privateKey,
        interceptors: interceptors,
        httpLogLevel: null,
      );
    } else {
      client = sdk.Client(
        accessToken: accessToken,
        interceptors: interceptors,
        httpLogLevel: null,
      );
    }
    scheduleMicrotask(() async {
      Future<void> refreshAccount() async {
        try {
          final response = await client.accountApi.getMe();
          await setAuth(auth!.copyWith(account: response.data));
        } catch (error) {
          d('refresh account failed. $error');
        }
      }

      if (isLogin) {
        final tgInitData = Telegram.instance.getTgInitData();
        if (tgInitData?.isNotEmpty ?? false) {
          // in telegram web app
          final data = await TelegramApi.instance.verifyInitData(tgInitData!);
          if (data.mixinId == auth!.account.userId) {
            await refreshAccount();
          } else {
            await loginByTelegram(tgInitData, user: data);
            _initCompleter.complete();
            return;
          }
        } else {
          await refreshAccount();
        }
      }
      await _initDatabase();
      _initCompleter.complete();
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

  final _initCompleter = Completer();

  // ignore: strict_raw_type
  Future? get initServiceFuture => _initCompleter.future;
  MixinDatabase? _mixinDatabase;

  bool get databaseInitialized => _mixinDatabase != null;

  MixinDatabase get mixinDatabase {
    if (!databaseInitialized) {
      throw StateError('the database is not initialized');
    }
    return _mixinDatabase!;
  }

  Future<void> loginByTelegram(String initData, {TelegramUser? user}) async {
    final data = user ?? await TelegramApi.instance.verifyInitData(initData);

    final client = sdk.Client(
      userId: data.mixinId,
      sessionId: data.sessionId,
      privateKey: data.privateKey,
      interceptors: interceptors,
    );

    final mixinResponse = await client.accountApi.getMe();

    await setAuth(Auth(
      accessToken: mixinResponse.data.userId,
      account: mixinResponse.data,
      credential: data,
    ));

    Session.instance.pinToken = base64Encode(decryptPinToken(
      data.pinToken,
      sdk.decodeBase64(data.privateKey),
    ));

    this.client = client;
    await _initDatabase();
    notifyListeners();
  }

  Future<void> loginByMixinAuth(String oauthCode) async {
    final response = await this
        .client
        .oauthApi
        .post(sdk.OauthRequest(Env.clientId, Env.clientSecret, oauthCode));

    final scope = response.data.scope;
    if (!scope.contains('ASSETS:READ') || !scope.contains('SNAPSHOTS:READ')) {
      throw ArgumentError('scope');
    }

    final token = response.data.accessToken;

    final client = sdk.Client(accessToken: token, interceptors: interceptors);

    final mixinResponse = await client.accountApi.getMe();

    await setAuth(Auth(
        accessToken: token, account: mixinResponse.data, credential: null));

    this.client = client;
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

    final fixedAssets = <sdk.Asset>[];
    for (final a in assets) {
      if (a.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
        a.name = 'BitTorrent Old';
        // ignore: cascade_invocations
        a.symbol = 'BTTOLD';
      }
      fixedAssets.add(a);
    }
    await mixinDatabase.transaction(() async {
      await mixinDatabase.assetDao.resetAllBalance();
      await mixinDatabase.assetDao.insertAllOnConflictUpdate(fixedAssets);
      await mixinDatabase.fiatDao.insertAllOnConflictUpdate(fiats);
    });

    const presetAssets = {
      xin,
      ethereum,
    };
    // make sure the some asset is in the database
    for (final presetAsset in presetAssets) {
      if (!assets.any((element) => element.assetId == presetAsset)) {
        await updateAsset(presetAsset);
      }
    }
  }

  Future<sdk.Asset> updateAsset(String assetId) async {
    final asset = (await client.assetApi.getAssetById(assetId)).data;
    if (asset.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
      asset.name = 'BitTorrent Old';
      // ignore: cascade_invocations
      asset.symbol = 'BTTOLD';
    }
    await mixinDatabase.assetDao.insert(asset);
    return asset;
  }

  Selectable<AssetResult> assetResults() {
    assert(isLogin);
    return mixinDatabase.assetDao.assetResults(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> assetResultsNotHidden() {
    assert(isLogin);
    return mixinDatabase.assetDao
        .assetResultsNotHidden(auth!.account.fiatCurrency);
  }

  Selectable<AssetResult> searchAssetResults(String keyword) {
    assert(isLogin);
    return mixinDatabase.assetDao
        .searchAssetResults(auth!.account.fiatCurrency, keyword.trim());
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
    return mixinDatabase.assetsExtraDao.updateHidden(assetId, hidden: hidden);
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
      client.snapshotApi.getSnapshots(
        assetId: assetId,
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
      ].where((element) => element != null).cast<Future<void>>());
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
      ].where((element) => element != null).cast<Future<void>>());
      return mixinDatabase.snapshotDao
          .snapshotsByIds(response.data.map((e) => e.snapshotId).toList())
          .get();
    });
  }

  Future<List<sdk.Snapshot>> updateAllSnapshots({
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
    return snapshots;
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
      ].where((element) => element != null).cast<Future<void>>());
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
        ].whereNotNull().cast<Future<void>>());
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshPendingDeposits(AssetResult asset) =>
      _refreshPendingDeposits(asset.assetId, asset.getDestination(), asset.tag);

  Future<void> _refreshPendingDeposits(
    String assetId,
    String? assetDestination,
    String? assetTag,
  ) async {
    if (assetDestination?.isNotEmpty ?? false) {
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
      assert(asset.getDestination() != null);
      await _refreshPendingDeposits(
          asset.assetId, asset.getDestination(), asset.tag);
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
      if (e.optionMixinError?.isForbidden ?? false) {
        rethrow;
      }
      d('update friends failed: $e');
    } catch (e) {
      d('update friends failed: $e');
    }
  }

  Future<List<User>> loadUsersIfNotExist(List<String> ids) async {
    if (ids.isEmpty) {
      return const [];
    }
    final cb = await _checkUsersExistWithReturnInsert(ids);
    await cb?.call();
    final list = await mixinDatabase.userDao.userByIds(ids).get();
    assert(list.length == ids.length,
        'count not match ${list.length} ${ids.length}');
    return list;
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final mixinDatabase = _mixinDatabase;
    _mixinDatabase = null;
    await mixinDatabase?.close();
  }

  @override
  List<Object?> get props => [
        client,
        _mixinDatabase,
      ];

  Future<void> searchAndUpdateAsset(String keyword) async {
    if (keyword.isEmpty) return;
    final mixinResponse = await client.assetApi.queryAsset(keyword);
    final fixedAssets = <sdk.Asset>[];
    for (final a in mixinResponse.data) {
      if (a.assetId == '47b13785-25e2-3c5c-ac6b-3713e9c31c22') {
        a.name = 'BitTorrent Old';
        // ignore: cascade_invocations
        a.symbol = 'BTTOLD';
      }
      fixedAssets.add(a);
    }
    await mixinDatabase.assetDao
        .insertAllOnConflictUpdateWithoutBalance(fixedAssets);
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

  Future<List<sdk.CollectibleOutput>> _loadUnspentTransactionOutputs({
    String? offset,
  }) async {
    // hash member id.
    final members = auth!.account.userId;

    String hashMemberId(String member) {
      try {
        final bytes =
            SHA3Digest(256).process(Uint8List.fromList(utf8.encode(member)));
        return hex.encode(bytes);
      } catch (e, s) {
        d('updateCollectibles error: $e, $s');
        return '';
      }
    }

    const threshold = 1;
    const limit = 500;

    final response = await client.collectibleApi.getOutputs(
      members: hashMemberId(members),
      limit: limit,
      threshold: threshold,
      offset: offset,
    );

    final outputs = <sdk.CollectibleOutput>[];
    for (final output in response.data) {
      final receivers = List<String>.from(output.receivers)..sort();
      if (receivers.join() != members) {
        d('receivers not match: outputId ${output.outputId}');
        continue;
      }
      if (output.receiversThreshold != threshold) {
        d('threshold not match: ${output.outputId}');
        continue;
      }
      if (output.state == sdk.CollectibleOutput.kStateSpent) {
        d('state not match: ${output.outputId}');
        continue;
      }
      outputs.add(output);
    }

    if (response.data.length == limit) {
      outputs.addAll(await _loadUnspentTransactionOutputs(
        offset: response.data.last.createdAt,
      ));
    }
    return outputs;
  }

  Future<void> updateCollectibles() async {
    try {
      final utxos = await _loadUnspentTransactionOutputs();
      final tokenIds = utxos.map((e) => e.tokenId).toList();
      await mixinDatabase.collectibleDao.updateOutputs(utxos);
      mixinDatabase.collectibleDao.removeNotExist(tokenIds);
      await refreshCollectiblesTokenIfNotExist(tokenIds);
    } on DioError catch (e, s) {
      if (e.optionMixinError?.isForbidden ?? false) {
        rethrow;
      }
      d('updateCollectibles error: $e, $s');
    } catch (e, s) {
      d('updateCollectibles error: $e, $s');
    }
  }

  Future<void> refreshCollectiblesTokenIfNotExist(List<String> tokenIds) async {
    final toRefresh =
        await mixinDatabase.collectibleDao.filterExistsTokens(tokenIds);

    final collectionIds = <String>{};
    for (final tokenId in toRefresh) {
      try {
        final response = await client.collectibleApi.getToken(tokenId);
        final token = response.data;
        collectionIds.add(token.collectionId);
        await mixinDatabase.collectibleDao.insertCollectible(token);
      } catch (error, stacktrace) {
        d('refreshTokenIfNotExist error:$tokenId $error $stacktrace');
      }
    }
    await refreshCollection(collectionIds.toList(), force: false);
  }

  Future<void> refreshCollection(
    List<String> collectionIds, {
    bool force = false,
  }) async {
    final toRefresh = force
        ? collectionIds
        : await mixinDatabase.collectibleDao
            .filterExistsCollections(collectionIds);
    for (final collectionId in toRefresh) {
      if (collectionId.isEmpty) {
        // Ignore empty collectionId;
        continue;
      }
      try {
        final response = await client.collectibleApi.collections(collectionId);
        final collection = response.data;
        await mixinDatabase.collectibleDao.insertCollection(collection);
      } catch (error, stacktrace) {
        d('refreshCollection error:$collectionId $error $stacktrace');
      }
    }
  }

  Stream<List<MapEntry<String, List<CollectibleItem>>>> groupedCollectibles() =>
      mixinDatabase.collectibleDao.getAllCollectibles().watch().map((event) {
        final grouped = event.groupListsBy((e) => e.collectionId);
        final result = <MapEntry<String, List<CollectibleItem>>>[];
        grouped.forEach((key, value) {
          if (key.isEmpty) {
            for (final item in value) {
              result.add(MapEntry(key, [item]));
            }
          } else {
            result.add(MapEntry(key, value));
          }
        });
        return result;
      });

  Stream<Collection?> collection(String collectionId) =>
      mixinDatabase.collectibleDao.collection(collectionId).watchSingleOrNull();

  Future<int> getPinErrorRemainCount() async {
    const pinErrorMax = 5;
    try {
      final response = await client.accountApi.pinLogs(
        category: 'PIN_INCORRECT',
        limit: pinErrorMax,
      );

      final count = response.data.fold<int>(0, (previousValue, element) {
        final onDayAgo = DateTime.now().subtract(const Duration(days: 1));
        if (DateTime.parse(element.createdAt).isAfter(onDayAgo)) {
          return previousValue + 1;
        }
        return previousValue;
      });

      return pinErrorMax - count;
    } catch (error, stacktrace) {
      e('getPinErrorCount error: $error, $stacktrace');
      return pinErrorMax;
    }
  }

  Future<Map<String, dynamic>> requestExternalProxy({
    required String method,
    required List<String> params,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/external/proxy',
      data: {
        'method': method,
        'params': params,
      },
    );
    return response.data!;
  }

  Future<void> sendRawTransaction(String rawTransaction) async =>
      requestExternalProxy(
        method: 'sendrawtransaction',
        params: [rawTransaction],
      );
}
