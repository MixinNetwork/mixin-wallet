import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/r.dart';
import '../../service/account_provider.dart';
import '../../util/extension/extension.dart';

class SymbolIconWithBorder extends StatelessWidget {
  const SymbolIconWithBorder({
    Key? key,
    required this.symbolUrl,
    this.chainUrl,
    required this.size,
    required this.chainSize,
    this.chainBorder = const BorderSide(color: Colors.white, width: 1),
  }) : super(key: key);

  final String symbolUrl;
  final String? chainUrl;
  final double size;
  final double chainSize;

  final BorderSide chainBorder;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size + chainBorder.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.all(chainBorder.width),
              child: Image.network(symbolUrl),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(chainBorder),
                ),
                child: Padding(
                  padding: EdgeInsets.all(chainBorder.width),
                  child: SizedBox.square(
                    dimension: chainSize,
                    child: Image.network(
                      chainUrl ?? '',
                      width: chainSize,
                      height: chainSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class PercentageChange extends HookWidget {
  const PercentageChange({
    Key? key,
    required this.changeUsd,
  }) : super(key: key);

  final String changeUsd;

  @override
  Widget build(BuildContext context) {
    final decimal = Decimal.tryParse(changeUsd) ?? Decimal.zero;
    final negative = decimal < Decimal.zero;

    final faitCurrency = useAccountFaitCurrency();

    final change = (decimal.abs() * Decimal.fromInt(100))
        .toDouble()
        .currencyFormatWithoutSymbol(faitCurrency);

    final text = Text(
      '$change%',
      textAlign: TextAlign.right,
      style: TextStyle(
        color: negative ? context.colorScheme.red : context.colorScheme.green,
        fontSize: 14,
      ),
    );
    if (decimal == Decimal.zero) {
      return text;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          negative ? R.resourcesDownRedSvg : R.resourcesUpGreenSvg,
          width: 6,
          height: 11,
          allowDrawingOutsideViewBox: true,
        ),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}
