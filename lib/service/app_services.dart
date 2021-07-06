import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../db/mixin_database.dart';
import '../db/web/construct_db.dart';
import 'auth/auth.dart';
import 'auth/auth_manager.dart';

const clientId = 'd0a44d9d-bb19-403c-afc5-ea26ea88123b';
const clientSecret =
    '29c9774449f38accd015638d463bc4f70242ecc39e154b939d47017ca9316420';

class AppServices extends ChangeNotifier with EquatableMixin {
  AppServices() {
    client = sdk.Client(accessToken: accessToken);
    _initDatabase();
  }

  late sdk.Client client;
  MixinDatabase? mixinDatabase;

  bool get databaseInitialized => mixinDatabase != null;

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
    mixinDatabase = await constructDb(auth!.account.identityNumber);
    notifyListeners();
  }

  Future<void> updateAssets() async {
    if (mixinDatabase == null) return;

    final list = await Future.wait([
      client.assetApi.getAssets(),
      client.accountApi.getFiats(),
    ]);
    final assets = (list.first as sdk.MixinResponse<List<sdk.Asset>>).data;
    final fiats = (list.last as sdk.MixinResponse<List<sdk.Fiat>>).data;

    await mixinDatabase!.transaction(() async {
      await mixinDatabase!.assetDao.insertAllOnConflictUpdate(assets);
      await mixinDatabase!.fiatDao.insertAllOnConflictUpdate(fiats);
    });
  }

  Stream<List<AssetResult>> watchAssets() {
    assert(mixinDatabase != null);
    return mixinDatabase!.assetDao.assets().watch();
  }

  Stream<List<Fiat>> watchFiats() {
    assert(mixinDatabase != null);
    return mixinDatabase!.fiatDao.fiats().watch();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    final _mixinDatabase = mixinDatabase;
    mixinDatabase = null;
    await _mixinDatabase?.close();
  }

  @override
  List<Object?> get props => [
        client,
        mixinDatabase,
      ];
}
