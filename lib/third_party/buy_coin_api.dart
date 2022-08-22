import '../db/mixin_database.dart';
import '../util/extension/extension.dart';
import 'banxa.dart';
import 'transak.dart';

class Quote {
  Quote({
    required this.transactionFee,
    required this.sourceAmount,
    required this.destAmount,
    required this.service,
    required this.networkFee,
    this.payload,
  });

  final String networkFee;
  final String transactionFee;
  final double sourceAmount;
  final double destAmount;
  final BuyService service;
  final dynamic payload;
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
    String fiatCurrency,
    String fiatAmount,
  );
}

class _TransakBuyCoinApiImpl implements BuyCoinApi {
  const _TransakBuyCoinApiImpl();

  @override
  Future<String> generatePayUrl(
    AssetResult asset,
    String userId,
    String fiatCurrency,
    String fiatAmount,
  ) async =>
      TransakApi.instance
          .generateTransakPayUrl(asset, fiatCurrency, fiatAmount);

  @override
  Future<Quote> getCurrencyPrice(
      AssetResult asset, String fiatAmount, String fiatCurrency) async {
    final result = await TransakApi.instance.getCurrencyPrice(
      asset,
      fiatAmount,
      fiatCurrency,
    );
    return Quote(
      transactionFee:
          '${result.feeBreakdown.firstWhereOrNull((e) => e?.id == 'transak_fee')?.value ?? 0} $fiatCurrency',
      networkFee:
          '${result.feeBreakdown.firstWhereOrNull((e) => e?.id == 'network_fee')?.value ?? 0} ${asset.symbol}',
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
    String fiatCurrency,
    String fiatAmount,
  ) =>
      BanxaApi.instance.createOrder(
        userId,
        asset,
        fiatCurrency,
        fiatAmount,
      );

  @override
  Future<Quote> getCurrencyPrice(
      AssetResult asset, String fiatAmount, String fiatCurrency) async {
    final result = await BanxaApi.instance.getTokenPrice(
      asset,
      fiatAmount,
      fiatCurrency,
    );
    final price = result.prices.reduce((value, element) =>
        value.coinAmount.asDecimal > element.coinAmount.asDecimal
            ? value
            : element);
    return Quote(
      sourceAmount: double.parse(price.fiatAmount),
      destAmount: double.parse(price.coinAmount),
      service: service,
      payload: price.paymentMethodId,
      transactionFee: '${price.feeAmount} $fiatCurrency',
      networkFee: '${price.networkFee ?? 0} $fiatCurrency',
    );
  }

  @override
  BuyService get service => BuyService.banxa;
}
