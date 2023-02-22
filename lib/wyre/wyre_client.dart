import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../service/env.dart';
import 'wyre_api.dart';
import 'wyre_constants.dart';

class WyreClient {
  WyreClient._() {
    _dio = Dio();
    _dio.options.baseUrl =
        kReleaseMode ? 'https://$wyreDomain' : 'https://$wyreTestDomain';
    _dio.options.responseType = ResponseType.json;
    _dio.options.headers['Authorization'] = 'Bearer ${Env.wyreSecret}';
    _dio.options.contentType = Headers.jsonContentType;
    _dio.interceptors.add(MixinLogInterceptor(HttpLogLevel.none));

    _api = WyreApi(dio: dio);
  }

  static WyreClient? _instance;

  static WyreClient get instance => _instance ??= WyreClient._();

  late Dio _dio;
  late WyreApi _api;

  Dio get dio => _dio;

  WyreApi get api => _api;
}
