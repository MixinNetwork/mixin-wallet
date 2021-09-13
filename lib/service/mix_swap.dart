import 'dart:convert';
import 'dart:math';

import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';

class MixSwap {
  MixSwap._() {
    _client = Client(null);
  }

  static MixSwap? _instance;

  static Client get client => (_instance ??= MixSwap._())._client;

  late Client _client;
}

const supportMaxSlippage = 1;
const mixSwapRetryErrorCode = 403;
const mixSwapUserId = '6a4a121d-9673-4a7e-a93e-cb9ca4bb83a2';

enum SwapPhase { checking, trading, done }

String buildMixSwapMemo(
  String targetUuid, {
  String routeId = '0',
  double? atLeastReceive,
}) {
  final memoBuffer = StringBuffer('0|')
    ..write(targetUuid)
    ..write('|')
    ..write(routeId);
  if (atLeastReceive != null) {
    memoBuffer
      ..write('|')
      ..write(atLeastReceive);
  }
  return base64Encode(utf8.encode(memoBuffer.toString()));
}

double calcSlippage(RouteData? routeData) {
  if (routeData == null || routeData.rank.isEmpty) {
    return 0;
  }
  var slippage = double.maxFinite;
  routeData.sources.forEach((source) {
    source.routes.forEach((route) {
      final priceImpact = double.tryParse(route.priceImpact ?? '0') ?? 0;
      slippage = min(slippage, priceImpact);
    });
  });
  return slippage * 100;
}

String displaySlippage(double slippage) {
  if (slippage < 0.01) {
    return '<1%';
  } else {
    return '${slippage.toStringAsFixed(2)}%';
  }
}
