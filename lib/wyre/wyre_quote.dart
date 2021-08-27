import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wyre_quote.g.dart';

@JsonSerializable()
class WyreQuote with EquatableMixin {
  WyreQuote({
    required this.sourceCurrency,
    required this.sourceAmount,
    required this.sourceAmountWithoutFees,
    required this.destCurrency,
    required this.destAmount,
    required this.exchangeRate,
    required this.equivalencies,
    required this.fees,
  });

  factory WyreQuote.fromJson(Map<String, dynamic> json) =>
      _$WyreQuoteFromJson(json);

  Map<String, dynamic> toJson() => _$WyreQuoteToJson(this);

  String sourceCurrency;
  double sourceAmount;
  double sourceAmountWithoutFees;
  String destCurrency;
  double destAmount;
  double exchangeRate;
  Map<String, dynamic> equivalencies;
  Map<String, dynamic> fees;

  @override
  List<Object> get props => [
        sourceCurrency,
        sourceAmount,
        sourceAmountWithoutFees,
        destCurrency,
        destAmount,
        exchangeRate,
        equivalencies,
        fees,
      ];
}
