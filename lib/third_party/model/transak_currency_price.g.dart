// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transak_currency_price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransakCurrencyPriceResult _$TransakCurrencyPriceResultFromJson(
        Map<String, dynamic> json) =>
    TransakCurrencyPriceResult(
      json['quoteId'] as String,
      (json['conversionPrice'] as num).toDouble(),
      (json['marketConversionPrice'] as num).toDouble(),
      (json['slippage'] as num).toDouble(),
      json['fiatCurrency'] as String,
      json['cryptoCurrency'] as String,
      json['paymentMethod'] as String,
      (json['fiatAmount'] as num).toDouble(),
      (json['cryptoAmount'] as num).toDouble(),
      json['isBuyOrSell'] as String,
      (json['feeDecimal'] as num).toDouble(),
      (json['totalFee'] as num).toDouble(),
      (json['feeBreakdown'] as List<dynamic>)
          .map((e) => FeeDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['nonce'] as int,
    );

Map<String, dynamic> _$TransakCurrencyPriceResultToJson(
        TransakCurrencyPriceResult instance) =>
    <String, dynamic>{
      'quoteId': instance.quoteId,
      'conversionPrice': instance.conversionPrice,
      'marketConversionPrice': instance.marketConversionPrice,
      'slippage': instance.slippage,
      'fiatCurrency': instance.fiatCurrency,
      'cryptoCurrency': instance.cryptoCurrency,
      'paymentMethod': instance.paymentMethod,
      'fiatAmount': instance.fiatAmount,
      'cryptoAmount': instance.cryptoAmount,
      'isBuyOrSell': instance.isBuyOrSell,
      'feeDecimal': instance.feeDecimal,
      'totalFee': instance.totalFee,
      'feeBreakdown': instance.feeBreakdown.map((e) => e.toJson()).toList(),
      'nonce': instance.nonce,
    };

FeeDetail _$FeeDetailFromJson(Map<String, dynamic> json) => FeeDetail(
      json['name'] as String,
      json['id'] as String,
      (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$FeeDetailToJson(FeeDetail instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'value': instance.value,
    };
