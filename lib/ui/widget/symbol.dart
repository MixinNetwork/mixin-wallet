import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';

class SymbolIconWithBorder extends StatelessWidget {
  const SymbolIconWithBorder({
    Key? key,
    required this.symbolUrl,
    required this.chainUrl,
    required this.size,
    required this.chainSize,
    this.chainBorder = const BorderSide(color: Colors.white, width: 1),
    this.symbolBorder = const BorderSide(color: Colors.white, width: 2),
  }) : super(key: key);

  final String symbolUrl;
  final String chainUrl;
  final double size;
  final double chainSize;

  final BorderSide chainBorder;
  final BorderSide symbolBorder;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.symmetric(
                        vertical: symbolBorder,
                        horizontal: symbolBorder,
                      ),
                    ),
                    child: Image.network(symbolUrl))),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.symmetric(
                    vertical: chainBorder,
                    horizontal: chainBorder,
                  ),
                ),
                child: Image.network(
                  chainUrl,
                  width: chainSize,
                  height: chainSize,
                ),
              ),
            ),
          ],
        ),
      );
}

class PercentageChange extends StatelessWidget {
  const PercentageChange({
    Key? key,
    required this.valid,
    required this.changeUsd,
  }) : super(key: key);

  final bool valid;
  final String changeUsd;

  @override
  Widget build(BuildContext context) {
    late String text;
    var color = context.theme.secondaryText;
    if (valid) {
      final decimal = Decimal.parse(changeUsd);
      color = decimal.isNegative ? context.theme.red : context.theme.green;
      final change = (decimal * Decimal.fromInt(100))
          .toDouble()
          .currencyFormatWithoutSymbol;
      print(change);
      text = '$change %';
    } else {
      text = context.l10n.none;
    }
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: color,
        fontSize: 14,
      ),
    );
  }
}
