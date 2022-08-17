import '../db/mixin_database.dart';
import 'banxa.dart';
import 'transak.dart';

class Quote {
  Quote({
    required this.fee,
    required this.sourceAmount,
    required this.destAmount,
    required this.service,
  });

  final double fee;
  final double sourceAmount;
  final double destAmount;
  final BuyService service;
}

enum BuyService {
  banxa,
  transak,
}

extension BuyServiceApi on BuyService {
  BuyCoinApi get api {
    switch (this) {
      case BuyService.banxa:
        return const _BanxaBuyCoinApiImpl();
      case BuyService.transak:
        return const _TransakBuyCoinApiImpl();
    }
  }
}

abstract class BuyCoinApi {
  BuyService get service;

  Future<Quote> getCurrencyPrice(
    AssetResult asset,
    String fiatAmount,
    String fiatCurrency,
  );

  Future<String> generatePayUrl(
    AssetResult asset,
    String userId,
    String faitCurrency,
    String faitAmount,
  );
}

class _TransakBuyCoinApiImpl implements BuyCoinApi {
  const _TransakBuyCoinApiImpl();

  // TODO
  @override
  Future<String> generatePayUrl(
    AssetResult asset,
    String userId,
    String faitCurrency,
    String faitAmount,
  ) async =>
      TransakApi.instance.generateTransakPayUrl(asset);

  @override
  Future<Quote> getCurrencyPrice(
      AssetResult asset, String fiatAmount, String fiatCurrency) async {
    final result = await TransakApi.instance.getCurrencyPrice(
      asset,
      fiatAmount,
      fiatCurrency,
    );
    return Quote(
      fee: result.totalFee,
      sourceAmount: result.fiatAmount,
      destAmount: result.cryptoAmount,
      service: service,
    );
  }

  @override
  BuyService get service => BuyService.transak;
}

class _BanxaBuyCoinApiImpl implements BuyCoinApi {
  const _BanxaBuyCoinApiImpl();

  @override
  Future<String> generatePayUrl(
    AssetResult asset,
    String userId,
    String faitCurrency,
    String faitAmount,
  ) =>
      BanxaApi.instance.createOrder(
        userId,
        asset,
        faitCurrency,
        faitAmount,
      );

  @override
  Future<Quote> getCurrencyPrice(
      AssetResult asset, String fiatAmount, String fiatCurrency) async {
    final result = await BanxaApi.instance.getTokenPrice(
      asset,
      fiatAmount,
      fiatCurrency,
    );
    return Quote(
      fee: double.parse(result.feeAmount),
      sourceAmount: double.parse(result.fiatAmount),
      destAmount: double.parse(result.coinAmount),
      service: service,
    );
  }

  @override
  BuyService get service => BuyService.banxa;
}
