import 'package:json_annotation/json_annotation.dart';

part 'transak_currency_price.g.dart';

@JsonSerializable()
class TransakCurrencyPriceResult {
  TransakCurrencyPriceResult(
    this.quoteId,
    this.conversionPrice,
    this.marketConversionPrice,
    this.slippage,
    this.fiatCurrency,
    this.cryptoCurrency,
    this.paymentMethod,
    this.fiatAmount,
    this.cryptoAmount,
    this.isBuyOrSell,
    this.feeDecimal,
    this.totalFee,
    this.feeBreakdown,
    this.nonce,
  );

  factory TransakCurrencyPriceResult.fromJson(Map<String, dynamic> json) =>
      _$TransakCurrencyPriceResultFromJson(json);

  final String quoteId;

  final double conversionPrice;

  final double marketConversionPrice;
  final double slippage;

  final String fiatCurrency;
  final String cryptoCurrency;
  final String paymentMethod;

  final double fiatAmount;

  final double cryptoAmount;

  final String isBuyOrSell;

  final double feeDecimal;

  final double totalFee;

  final List<FeeDetail> feeBreakdown;

  final int nonce;

  Map<String, dynamic> toJson() => _$TransakCurrencyPriceResultToJson(this);
}

@JsonSerializable()
class FeeDetail {
  FeeDetail(this.name, this.id, this.value);

  factory FeeDetail.fromJson(Map<String, dynamic> json) =>
      _$FeeDetailFromJson(json);

  final String name;
  final String id;
  final double value;

  Map<String, dynamic> toJson() => _$FeeDetailToJson(this);
}
