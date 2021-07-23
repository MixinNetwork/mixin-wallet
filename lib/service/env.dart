import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envify(path: kReleaseMode ? '.production.env' : '.development.env')
abstract class Env {
  static const clientId = _Env.clientId;
  static const clientSecret = _Env.clientSecret;
}
