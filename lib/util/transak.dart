import 'package:flutter/foundation.dart';

import '../db/mixin_database.dart';
import '../service/env.dart';

String generateTransakPayUrl(AssetResult asset) {
  final uri = Uri.https(
    kReleaseMode ? 'global.transak.com' : 'staging-global.transak.com',
    '',
    {
      'apiKey': Env.transakApiKey,
      'cryptoCurrencyCode': asset.symbol,
      'walletAddress': asset.destination,
      'networks': 'ethereum',
    },
  );
  return uri.toString();
}
