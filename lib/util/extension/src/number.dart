part of '../extension.dart';

extension CurrencyExtension on dynamic {
  String get currencyFormat =>
      currentCurrencyNumberFormat.format(num.tryParse('$this'));

  String get currencyFormatWithoutSymbol =>
      currencyFormat.replaceAll('[^0123456789.,-]', '');

  String get currencyFormatCoin => NumberFormat().format(num.tryParse('$this'));

  NumberFormat get currentCurrencyNumberFormat =>
      NumberFormat.simpleCurrency(name: auth?.account.fiatCurrency);
}

extension StringCurrencyExtension on String {
  bool get isZero => (double.tryParse(this) ?? 0.0) == 0;

  Decimal get asDecimal => Decimal.parse(this);
}

extension DoubleCurrencyExtension on num {
  Decimal get asDecimal => Decimal.parse('$this');
}

extension AssetResultExtension on AssetResult {
  Decimal get amountOfUsd => balance.asDecimal * priceUsd.asDecimal;
  Decimal get amountOfBtc => balance.asDecimal * priceBtc.asDecimal;
  Decimal get amountOfCurrentCurrency =>
      balance.asDecimal * priceUsd.asDecimal * fiatRate.asDecimal;

  Decimal get usdUnitPrice => priceUsd.asDecimal * fiatRate.asDecimal;

  bool get needShowMemo => tag?.isNotEmpty == true;

  String getTip(BuildContext context) {
    switch (chainId) {
      case bitcoin:
        return context.l10n.depositTipBtc;
      case ethereum:
        return context.l10n.depositTipEth;
      case eos:
        return context.l10n.depositTipEos;
      case tron:
        return context.l10n.depositTipTron;
      default:
        return context.l10n.depositTip(symbol);
    }
  }
}
