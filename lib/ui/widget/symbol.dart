import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../util/extension/extension.dart';

class SymbolIcon extends StatelessWidget {
  const SymbolIcon({
    Key? key,
    required this.symbolUrl,
    required this.chainUrl,
    this.size = 44,
    this.chinaSize = 10,
    this.chinaBorder = 2,
  }) : super(key: key);

  final String symbolUrl;
  final String chainUrl;
  final double size;
  final double chinaSize;
  final double chinaBorder;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: size,
        width: size,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _SymbolCustomClipper(
                  chainPlaceholderSize: chinaSize + chinaBorder,
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.network(
                  symbolUrl,
                ),
              ),
            ),
            Positioned(
              left: chinaBorder / 2,
              bottom: chinaBorder / 2,
              child: Image.network(
                chainUrl,
                width: chinaSize,
                height: chinaSize,
              ),
            ),
          ],
        ),
      );
}

class _SymbolCustomClipper extends CustomClipper<Path> with EquatableMixin {
  _SymbolCustomClipper({this.chainPlaceholderSize = 12});

  final double chainPlaceholderSize;

  @override
  Path getClip(Size size) {
    assert(size.shortestSide > chainPlaceholderSize);

    final symbol = Path()..addOval(Offset.zero & size);
    final chain = Path()
      ..addOval(Offset(0, size.height - chainPlaceholderSize) &
          Size.square(chainPlaceholderSize));

    return Path.combine(PathOperation.difference, symbol, chain);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      this != oldClipper;

  @override
  List<Object?> get props => [chainPlaceholderSize];
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
      text = '${(decimal * Decimal.fromInt(100)).toDouble().currencyFormat} %';
    } else {
      text = context.l10n.none;
    }
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontFamily: 'Nunito',
      ),
    );
  }
}
