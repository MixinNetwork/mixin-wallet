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
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            children: [
              SymbolIconWithBorder(
                symbolUrl: data.iconUrl,
                chainUrl: data.chainIconUrl,
                size: 44,
                chainSize: 10,
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
                        color: context.theme.text,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      context.l10n.approxOf(
                          data.amountOfCurrentCurrency.currencyFormat),
                      style: TextStyle(
                        color: context.theme.secondaryText,
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
