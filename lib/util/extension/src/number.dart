part of '../extension.dart';

extension CurrencyExtension on dynamic {
  String get currencyFormat => NumberFormat('#,###.##').format(this);
  String get currencyFormat00 => NumberFormat().format(this);
}
