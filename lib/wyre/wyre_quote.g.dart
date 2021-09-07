// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wyre_quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WyreQuote _$WyreQuoteFromJson(Map<String, dynamic> json) => WyreQuote(
      sourceCurrency: json['sourceCurrency'] as String,
      sourceAmount: (json['sourceAmount'] as num).toDouble(),
      sourceAmountWithoutFees:
          (json['sourceAmountWithoutFees'] as num).toDouble(),
      destCurrency: json['destCurrency'] as String,
      destAmount: (json['destAmount'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      equivalencies: json['equivalencies'] as Map<String, dynamic>,
      fees: json['fees'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WyreQuoteToJson(WyreQuote instance) => <String, dynamic>{
      'sourceCurrency': instance.sourceCurrency,
      'sourceAmount': instance.sourceAmount,
      'sourceAmountWithoutFees': instance.sourceAmountWithoutFees,
      'destCurrency': instance.destCurrency,
      'destAmount': instance.destAmount,
      'exchangeRate': instance.exchangeRate,
      'equivalencies': instance.equivalencies,
      'fees': instance.fees,
    };
