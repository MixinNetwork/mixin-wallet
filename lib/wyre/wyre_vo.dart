import 'dart:math';

import '../util/mixin_context.dart';

import 'wyre_constants.dart';

class WyreFiat {
  WyreFiat(this.name, this.flag, this.desc);

  final String name;
  final String flag;
  final String desc;

  WyreServiceArea get area =>
      name == 'USD' ? WyreServiceArea.us : WyreServiceArea.international;
}

List<WyreFiat> getWyreFiatList() {
  final fiatList = <WyreFiat>[];
  for (var i = 0; i < supportedFiats.length; i++) {
    fiatList.add(WyreFiat(
      supportedFiats[i],
      supportedFiatsFlag[i],
      supportedFiatNames[i],
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

String getCountry() {
  try {
    final ctx = getMixinContext();
    final locale = ctx['locale'].toString();
    final country = locale.substring(locale.length - 2, locale.length);
    if (supportedContries.contains(country.toUpperCase())) {
      return country;
    } else {
      return 'US';
    }
  } catch (_) {
    return 'US';
  }
}
