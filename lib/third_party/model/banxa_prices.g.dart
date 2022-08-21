// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banxa_prices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BanxaPricesResult _$BanxaPricesResultFromJson(Map<String, dynamic> json) =>
    BanxaPricesResult(
      json['spot_price'] as String,
      BanxaPrices.fromJson(json['prices'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BanxaPricesResultToJson(BanxaPricesResult instance) =>
    <String, dynamic>{
      'spot_price': instance.spotPrice,
      'prices': instance.prices.toJson(),
    };

BanxaPrices _$BanxaPricesFromJson(Map<String, dynamic> json) => BanxaPrices(
      json['payment_method_id'] as int,
      json['type'] as String,
      json['spot_price_fee'] as int,
      json['spot_price_including_fee'] as String,
      json['coin_amount'] as String,
      json['coin_code'] as String,
      json['fiat_amount'] as String,
      json['fiat_code'] as String,
      json['fee_amount'] as String,
    );

Map<String, dynamic> _$BanxaPricesToJson(BanxaPrices instance) =>
    <String, dynamic>{
      'payment_method_id': instance.paymentMethodId,
      'type': instance.type,
      'spot_price_fee': instance.spotPriceFee,
      'spot_price_including_fee': instance.spotPriceIncludingFee,
      'coin_amount': instance.coinAmount,
      'coin_code': instance.coinCode,
      'fiat_amount': instance.fiatAmount,
      'fiat_code': instance.fiatCode,
      'fee_amount': instance.feeAmount,
    };