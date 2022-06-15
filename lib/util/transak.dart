import 'package:flutter/foundation.dart';

import '../db/mixin_database.dart';
import 'web/web_utils_dummy.dart' if (dart.library.html) 'web/web_utils.dart';

const _kStagingKey = '8a81eca9-c2da-402d-ba4f-f3c570a449a3';
const _kProductionKey = 'e9054373-784b-49c2-93d1-1362349dae01';

String generateTransakPayUrl(AssetResult asset) {
  final uri = Uri.https(
    kReleaseMode ? 'global.transak.com' : 'staging-global.transak.com',
    '',
    {
      'apiKey': kReleaseMode ? _kProductionKey : _kStagingKey,
      'cryptoCurrencyCode': asset.symbol,
      'walletAddress': asset.destination,
      'networks': 'ethereum',
      'redirectUrl': '${locationOrigin()}/#/tokens/${asset.assetId}',
    },
  );
  return uri.toString();
}
