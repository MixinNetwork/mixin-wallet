import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../brightness_theme_data.dart';
import 'pie_chart.dart';

@immutable
class _AssetChartItem extends PieChartItem {
  const _AssetChartItem({
    required this.color,
    required this.name,
    required this.amount,
    this.isOther = false,
  });

  factory _AssetChartItem.fromAsset(AssetResult asset, Color color) =>
      _AssetChartItem(
        color: color,
        name: asset.name,
        amount: asset.amountOfUsd.toDouble(),
      );

  @override
  final Color color;
  final String name;
  @override
  final double amount;
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

      var otherAmount = 0.0;
      for (var i = 0; i < sorted.length; i++) {
        if (i < 3) {
          items.add(_AssetChartItem.fromAsset(sorted[i], assetColors[i]));
        } else {
          otherAmount += sorted[i].amountOfUsd.toDouble();
        }
      }
      items.add(
        _AssetChartItem(
          color: assetColors[3],
          name: '',
          amount: otherAmount,
          isOther: true,
        ),
      );
      return items;
    }, [assets]);

    assert(assetChartItems.length == 4);

    final percents = useMemoized(() {
      final totalAmount = assetChartItems.fold<double>(
          0, (previousValue, e) => previousValue + e.amount);

      final percents = List.filled(4, 0);

      var remainPercent = 10000;
      for (var i = 0; i < assetChartItems.length; i++) {
        final item = assetChartItems[i];
        if (item.amount == 0) {
          percents[i] = 0;
        } else {
          final percent = ((item.amount / totalAmount) * 10000).round();
          remainPercent -= percent;
          percents[i] = percent;
        }
      }

      if (remainPercent > 0) {
        for (var i = assetChartItems.length - 1; i >= 0; i--) {
          if (percents[i] != 0) {
            percents[i] += remainPercent;
          }
        }
      } else if (remainPercent < 0) {
        for (var i = assetChartItems.length - 1; i >= 0; i--) {
          if (percents[i] > remainPercent.abs()) {
            percents[i] -= remainPercent.abs();
          }
        }
      }
      return percents;
    }, [assetChartItems]);

    assert(percents.length == 4);

    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: RepaintBoundary(
              child: PieChart(items: assetChartItems),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              _ChartDescriptionTile(
                item: assetChartItems[0],
                percent: percents[0],
              ),
              _ChartDescriptionTile(
                item: assetChartItems[2],
                percent: percents[2],
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
                item: assetChartItems[1],
                percent: percents[1],
              ),
              _ChartDescriptionTile(
                item: assetChartItems[3],
                percent: percents[3],
              ),
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
    required this.percent,
  }) : super(key: key);

  final _AssetChartItem item;

  /// The percent of total. The value has been magnified by 10000 times
  final int percent;

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
            '${percent / 100}%',
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.thirdText,
            ),
          )
        ],
      );
}
