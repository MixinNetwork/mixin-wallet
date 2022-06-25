import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../db/mixin_database.dart';
import 'constants.dart';
import 'web/web_utils_dummy.dart' if (dart.library.html) 'web/web_utils.dart';

const _kStagingKey = '8a81eca9-c2da-402d-ba4f-f3c570a449a3';
const _kProductionKey = 'e9054373-784b-49c2-93d1-1362349dae01';

String generateTransakPayUrl(AssetResult asset) {
  var walletAddress = asset.destination;
  if (asset.assetId == bitcoin) {
    final de = jsonDecode(asset.depositEntries!) as List;
    final depositEntries = de
        .map((obj) => DepositEntry.fromJson(obj as Map<String, dynamic>))
        .toList();

    for (final entry in depositEntries) {
      if (entry.properties!.contains('SegWit')) {
        walletAddress = entry.destination;
        break;
      }
    }
  }
  final uri = Uri.https(
    kReleaseMode ? 'global.transak.com' : 'staging-global.transak.com',
    '',
    {
      'apiKey': kReleaseMode ? _kProductionKey : _kStagingKey,
      'cryptoCurrencyCode': asset.symbol,
      'walletAddress': walletAddress,
      'networks': 'ethereum',
      'redirectUrl': '${locationOrigin()}/#/tokens/${asset.assetId}',
    },
  );
  return uri.toString();
}
