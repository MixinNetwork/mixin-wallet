import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../db/dao/extension.dart';
import '../db/mixin_database.dart';
import '../util/web/web_utils_dummy.dart'
    if (dart.library.html) '../util/web/web_utils.dart';
import 'model/transak_currency_price.dart';

const _kStagingKey = '8a81eca9-c2da-402d-ba4f-f3c570a449a3';
const _kProductionKey = 'e9054373-784b-49c2-93d1-1362349dae01';

class TransakApi {
  TransakApi() {
    _dio.options.baseUrl = kReleaseMode
        ? 'https://api.transak.com/api/v2'
        : 'https://staging-api.transak.com/api/v2';
  }

  static final instance = TransakApi();

  final _dio = Dio();

  String generateTransakPayUrl(
    AssetResult asset,
    String fiatCurrency,
    String fiatAmount,
  ) {
    final walletAddress = asset.getDestination();
    final uri = Uri.https(
      kReleaseMode ? 'global.transak.com' : 'staging-global.transak.com',
      '',
      {
        'apiKey': kReleaseMode ? _kProductionKey : _kStagingKey,
        'cryptoCurrencyCode': asset.symbol,
        'walletAddress': walletAddress,
        'networks': 'ethereum',
        'redirectUrl': '${locationOrigin()}/#/tokens/${asset.assetId}',
        'fiatCurrency': fiatCurrency,
        'fiatAmount': fiatAmount,
      },
    );
    return uri.toString();
  }

  // https://docs.transak.com/docs/transak-docs/7965daf558366-3-get-a-currency-price
  // path: /currencies/price
  Future<TransakCurrencyPriceResult> getCurrencyPrice(
    AssetResult asset,
    String fiatAmount,
    String fiatCurrency,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/currencies/price',
      queryParameters: {
        'fiatAmount': fiatAmount,
        'partnerApiKey': kReleaseMode ? _kProductionKey : _kStagingKey,
        'cryptoCurrency': asset.symbol,
        'fiatCurrency': fiatCurrency,
        'isBuyOrSell': 'BUY',
        'network': 'ethereum',
      },
    );
    final data = response.data?['response'];
    if (data == null) {
      throw Exception('No data');
    }
    final result = TransakCurrencyPriceResult.fromJson((data as Map).cast());
    debugPrint('getCurrencyPrice: ${result.totalFee}');
    return result;
  }
}
