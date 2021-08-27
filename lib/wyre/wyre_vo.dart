import 'dart:math';

import 'wyre_constants.dart';

class WyreRate {
  WyreRate(
    this.name,
    this.value,
  );

  final String name;
  final double value;

  @override
  String toString() => '{$name: $value}';
}

class WyreFiat {
  WyreFiat(this.name, this.flag, this.symbol);

  final String name;
  final String flag;
  final String symbol;

  WyreServiceArea get area =>
      name == 'USD' ? WyreServiceArea.us : WyreServiceArea.international;

  @override
  String toString() => '{$name $symbol}';
}

List<WyreFiat> getWyreFiatList() {
  final fiatList = <WyreFiat>[];
  for (var i = 0; i < supportedFiats.length; i++) {
    fiatList.add(WyreFiat(
      supportedFiats[i],
      supportedFiatsFlag[i],
      supportedFiatsSymbol[i],
    ));
  }
  return fiatList;
}

enum WyreServiceArea {
  us,
  international,
}

const minTransactionFee = 5;

String calcTransactionFee(double price, WyreServiceArea wyreServiceArea) {
  switch (wyreServiceArea) {
    case WyreServiceArea.us:
      return min(price * 0.029 + 0.3, minTransactionFee).toString();
    default:
      return min(price * 0.039 + 0.3, minTransactionFee).toString();
  }
}

enum WyrePayType { debitCard, applePay }

extension WyrePayTypeExtension on WyrePayType {
  String forReservation() =>
      this == WyrePayType.debitCard ? 'debit-card' : 'apple-pay';

  String forQuote() =>
      this == WyrePayType.debitCard ? 'DEBIT_CARD' : 'APPLE_PAY';
}
