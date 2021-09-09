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
    return '<0.01%';
  } else {
    return '${slippage.toStringAsFixed(2)}%';
  }
}
