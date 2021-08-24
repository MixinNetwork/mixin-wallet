import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../brightness_theme_data.dart';

@immutable
class _AssetChartItem {
  const _AssetChartItem({
    required this.color,
    required this.name,
    required this.amountOfUsd,
    this.isOther = false,
  });

  factory _AssetChartItem.fromAsset(AssetResult asset, Color color) =>
      _AssetChartItem(
        color: color,
        name: asset.name,
        amountOfUsd: asset.amountOfUsd,
      );

  final Color color;
  final String name;
  final Decimal amountOfUsd;
  final bool isOther;
}

class AssetsAnalysisChartLayout extends HookWidget {
  const AssetsAnalysisChartLayout({
    Key? key,
    required this.assets,
  })  : assert(assets.length >= 4),
        super(key: key);

  final List<AssetResult> assets;

  @override
  Widget build(BuildContext context) {
    final assetChartItems = useMemoized(() {
      if (assets.isEmpty) {
        return const <_AssetChartItem>[];
      }
      final sorted = assets.toList()
        ..sort((a, b) => b.amountOfUsd.compareTo(a.amountOfUsd));
      assert(sorted.length >= 4);

      final items = <_AssetChartItem>[];
      var otherAmount = Decimal.zero;
      for (var i = 0; i < sorted.length; i++) {
        if (i < 3) {
          items.add(_AssetChartItem.fromAsset(sorted[i], assetColors[i]));
        } else {
          otherAmount += sorted[i].amountOfUsd;
        }
      }
      items.add(
        _AssetChartItem(
          color: assetColors[3],
          name: '',
          amountOfUsd: otherAmount,
          isOther: true,
        ),
      );
      return items;
    }, [assets]);

    assert(assetChartItems.length == 4);

    final data = PieChartData(
      sections: assetChartItems
          .map((e) => PieChartSectionData(
                value: e.amountOfUsd.toDouble(),
                color: e.color,
                showTitle: false,
                radius: 16,
              ))
          .toList(),
      centerSpaceRadius: 16,
      sectionsSpace: 2,
      startDegreeOffset: 270,
    );
    final totalAmount = assetChartItems.fold<Decimal>(Decimal.zero,
        (previousValue, element) => previousValue + element.amountOfUsd);
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: PieChart(data),
          ),
          const SizedBox(width: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _ChartDescriptionTile(
                    item: assetChartItems[0],
                    totalAmount: totalAmount,
                  ),
                  _ChartDescriptionTile(
                    item: assetChartItems[1],
                    totalAmount: totalAmount,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _ChartDescriptionTile(
                    item: assetChartItems[2],
                    totalAmount: totalAmount,
                  ),
                  _ChartDescriptionTile(
                    item: assetChartItems[3],
                    totalAmount: totalAmount,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class _ChartDescriptionTile extends StatelessWidget {
  const _ChartDescriptionTile({
    Key? key,
    required this.item,
    required this.totalAmount,
  }) : super(key: key);

  final _AssetChartItem item;
  final Decimal totalAmount;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
            width: 10,
            height: 10,
          ),
          const SizedBox(width: 8),
          Text(
            item.isOther ? context.l10n.other : item.name,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.primaryText,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.amountOfUsd * Decimal.fromInt(100) ~/ totalAmount}%',
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.thirdText,
            ),
          )
        ],
      );
}
