import 'package:json_annotation/json_annotation.dart';

part 'banxa_prices.g.dart';

@JsonSerializable()
class BanxaPricesResult {
  BanxaPricesResult(this.spotPrice, this.prices);

  factory BanxaPricesResult.fromJson(Map<String, dynamic> json) =>
      _$BanxaPricesResultFromJson(json);

  @JsonKey(name: 'spot_price')
  final String spotPrice;

  final List<BanxaPrices> prices;

  Map<String, dynamic> toJson() => _$BanxaPricesResultToJson(this);
}

@JsonSerializable()
class BanxaPrices {
  BanxaPrices(
    this.paymentMethodId,
    this.type,
    this.spotPriceFee,
    this.spotPriceIncludingFee,
    this.coinAmount,
    this.coinCode,
    this.fiatAmount,
    this.fiatCode,
    this.feeAmount,
    this.networkFee,
  );

  factory BanxaPrices.fromJson(Map<String, dynamic> json) =>
      _$BanxaPricesFromJson(json);

  @JsonKey(name: 'payment_method_id')
  final int paymentMethodId;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'spot_price_fee')
  final String spotPriceFee;

  @JsonKey(name: 'spot_price_including_fee')
  final String spotPriceIncludingFee;

  @JsonKey(name: 'coin_amount')
  final String coinAmount;

  @JsonKey(name: 'coin_code')
  final String coinCode;

  @JsonKey(name: 'fiat_amount')
  final String fiatAmount;

  @JsonKey(name: 'fiat_code')
  final String fiatCode;

  @JsonKey(name: 'fee_amount')
  final String feeAmount;

  @JsonKey(name: 'network_fee')
  final String? networkFee;

  Map<String, dynamic> toJson() => _$BanxaPricesToJson(this);
}
