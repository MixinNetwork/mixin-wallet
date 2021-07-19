import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import 'symbol.dart';

class AssetPrice extends StatelessWidget {
  const AssetPrice({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AssetResult data;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PercentageChange(
            valid: !data.priceUsd.isZero,
            changeUsd: data.changeUsd,
          ),
          Text(
            data.usdUnitPrice.currencyFormat,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: context.theme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      );
}
