import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';

import '../db/dao/extension.dart';
import '../db/mixin_database.dart';
import '../service/env.dart';
import '../util/logger.dart';
import '../util/web/web_utils_dummy.dart'
    if (dart.library.html) '../util/web/web_utils.dart';
import 'model/banxa_prices.dart';

const _domain = 'mixin.banxa.com';
const _sandboxDomain = 'mixin.banxa-sandbox.com';
const _apiKey = Env.banxaApiKey;
const _apiSecret = Env.banxaApiSecret;

String _hmac(String message, String secret) {
  final bytes = JWTAlgorithm.HS256.sign(
    SecretKey(secret),
    Uint8List.fromList(utf8.encode(message)),
  );
  return hex.encode(bytes);
}

class BanxaApi {
  BanxaApi() {
    _dio.options.baseUrl = 'https://$_domain';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) {
        // final nonce = DateTime.now().millisecondsSinceEpoch.toString();
        //
        // final method = options.method.toUpperCase();
        // final query = options.path;
        //
        // final signature = StringBuffer('$method\n$query\n$nonce');
        //
        // if (options.queryParameters.isNotEmpty) {
        //   final payload = jsonEncode(options.queryParameters);
        //   signature.write('\n$payload');
        // }
        // d('banax request signature: $signature ${_hmac(signature.toString(), _apiSecret)}');
        // options.headers['Authorization'] =
        //     'Bearer $_apiKey:${_hmac(signature.toString(), _apiSecret)}:$nonce';
        handler.next(options);
      }),
    );
  }

  static final instance = BanxaApi();

  final _dio = Dio();

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic> queryParameters = const {},
  }) async {
    var query = path;
    if (queryParameters.isNotEmpty) {
      query += '?${Transformer.urlEncodeMap(queryParameters)}';
    }
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = 'GET\n$query\n$nonce';
    final response = await _dio.get<Map<String, dynamic>>(query,
        options: Options(headers: {
          'Authorization':
              'Bearer $_apiKey:${_hmac(signature, _apiSecret)}:$nonce',
        }));
    if (response.data == null) {
      throw Exception('$path response data is null');
    }
    return response.data!;
  }

  // https://docs.banxa.com/reference/get-prices
  // path: /prices
  Future<BanxaPrices> getTokenPrice(
    AssetResult asset,
    String fiatAmount,
    String fiatCurrency,
  ) async {
    final response = await _get(
      '/api/prices',
      queryParameters: {
        'source': fiatCurrency,
        'target': asset.symbol,
        'source_amount': fiatAmount,
        'blockchain': 'ETH',
      },
    );
    final data = response['data'];
    if (data == null) {
      throw Exception('No data');
    }
    final result = BanxaPricesResult.fromJson((data as Map).cast());
    return result.prices;
  }

  // https://docs.banxa.com/reference/create-order
  // path: /orders
  Future<String> createOrder(
    String userId,
    AssetResult asset,
    String faitCurrency,
    String faitAmount,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/orders',
      data: {
        'source': faitCurrency,
        'target': asset.symbol,
        'source_amount': faitAmount,
        'blockchain': 'ETH',
        'wallet_address': asset.getDestination(),
        'return_url_on_success':
            '${locationOrigin()}/#/tokens/${asset.assetId}',
      },
    );
    final data = response.data?['data'];
    if (data == null) {
      throw Exception('No data');
    }
    // data.order.checkout_url
    final url = data['order']['checkout_url'];
    d('banax order url: $url');
    return url as String;
  }
}
