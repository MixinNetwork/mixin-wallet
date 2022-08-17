import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envify(path: '.development.env')
abstract class _DevEnv {
  static const clientId = __DevEnv.clientId;
  static const clientSecret = __DevEnv.clientSecret;
  static const wyreAccount = __DevEnv.wyreAccount;
  static const wyreSecret = __DevEnv.wyreSecret;
  static const banxaApiKey = __DevEnv.banxaApiKey;
  static const banxaApiSecret = __DevEnv.banxaApiSecret;
}

@Envify(path: '.production.env')
abstract class _ProdEnv {
  static const clientId = __ProdEnv.clientId;
  static const clientSecret = __ProdEnv.clientSecret;
  static const wyreAccount = __ProdEnv.wyreAccount;
  static const wyreSecret = __ProdEnv.wyreSecret;
  static const banxaApiKey = __ProdEnv.banxaApiKey;
  static const banxaApiSecret = __ProdEnv.banxaApiSecret;
}

class Env {
  static const clientId = kReleaseMode ? _ProdEnv.clientId : _DevEnv.clientId;
  static const clientSecret =
      kReleaseMode ? _ProdEnv.clientSecret : _DevEnv.clientSecret;
  static const wyreSecret =
      kReleaseMode ? _ProdEnv.wyreSecret : _DevEnv.wyreSecret;
  static const wyreAccount =
      kReleaseMode ? _ProdEnv.wyreAccount : _DevEnv.wyreAccount;
  static const banxaApiKey =
      kReleaseMode ? _ProdEnv.banxaApiKey : _DevEnv.banxaApiKey;
  static const banxaApiSecret =
      kReleaseMode ? _ProdEnv.banxaApiSecret : _DevEnv.banxaApiSecret;
}
