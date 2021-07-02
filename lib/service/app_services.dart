import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import 'auth/auth.dart';
import 'auth/auth_manager.dart';

const clientId = 'd0a44d9d-bb19-403c-afc5-ea26ea88123b';
const clientSecret =
    '29c9774449f38accd015638d463bc4f70242ecc39e154b939d47017ca9316420';

class AppServices extends ChangeNotifier {
  AppServices() {
    client = Client(accessToken: accessToken);
  }

  late Client client;

  Future<void> login(String oauthCode) async {
    final response = await client.oauthApi
        .post(OauthRequest(clientId, clientSecret, oauthCode));

    final scope = response.data.scope;
    if (!scope.contains('ASSETS:READ') || !scope.contains('SNAPSHOTS:READ')) {
      throw ArgumentError('scope');
    }

    final token = response.data.accessToken;

    final _client = Client(accessToken: token);

    final mixinResponse = await _client.accountApi.getMe();

    await setAuth(Auth(accessToken: token, account: mixinResponse.data));

    client = _client;
    notifyListeners();
  }
}
