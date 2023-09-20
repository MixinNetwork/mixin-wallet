import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envied(path: '.development.env')
abstract class _DevEnv {
  @EnviedField(varName: 'CLIENT_ID')
  static const String clientId = __DevEnv.clientId;
  @EnviedField(varName: 'CLIENT_SECRET')
  static const String clientSecret = __DevEnv.clientSecret;
}

@Envied(path: '.production.env')
abstract class _ProdEnv {
  @EnviedField(varName: 'CLIENT_ID')
  static const String clientId = __ProdEnv.clientId;
  @EnviedField(varName: 'CLIENT_SECRET')
  static const String clientSecret = __ProdEnv.clientSecret;
}

class Env {
  static const clientId = kReleaseMode ? _ProdEnv.clientId : _DevEnv.clientId;
  static const clientSecret =
      kReleaseMode ? _ProdEnv.clientSecret : _DevEnv.clientSecret;
}
