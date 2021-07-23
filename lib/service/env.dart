import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envify(path: '.development.env')
abstract class _DevEnv {
  static const clientId = __DevEnv.clientId;
  static const clientSecret = __DevEnv.clientSecret;
}

@Envify(path: '.production.env')
abstract class _ProdEnv {
  static const clientId = __ProdEnv.clientId;
  static const clientSecret = __ProdEnv.clientSecret;
}

class Env {
  static const clientId = kReleaseMode ? _ProdEnv.clientId : _DevEnv.clientId;
  static const clientSecret = kReleaseMode ? _ProdEnv.clientSecret : _DevEnv.clientSecret;
}
