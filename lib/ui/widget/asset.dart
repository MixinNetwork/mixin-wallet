import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../router/mixin_routes.dart';
import 'symbol.dart';

class AssetWidget extends StatelessWidget {
  const AssetWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AssetResult data;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.push(assetDetailPath.toUri({'id': data.assetId})),
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SymbolIconWithBorder(
                symbolUrl: data.iconUrl,
                chainUrl: data.chainIconUrl,
                size: 40,
                chainSize: 14,
                chainBorder: BorderSide(
                  color: context.colorScheme.background,
                  width: 1.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${data.balance} ${data.symbol}'.overflow,
                      style: TextStyle(
                        color: context.colorScheme.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.l10n.approxOf(
                          data.amountOfCurrentCurrency.currencyFormat),
                      style: TextStyle(
                        color: context.colorScheme.thirdText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              AssetPrice(data: data),
            ],
          ),
        ),
      );
}

class AssetPrice extends StatelessWidget {
  const AssetPrice({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AssetResult data;

  @override
  Widget build(BuildContext context) {
    final valid = !data.priceUsd.isZero;
    if (!valid) {
      return Text(
        context.l10n.none,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: context.colorScheme.thirdText,
          fontSize: 14,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PercentageChange(
          changeUsd: data.changeUsd,
        ),
        Text(
          data.usdUnitPrice.currencyFormat,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: context.colorScheme.thirdText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
